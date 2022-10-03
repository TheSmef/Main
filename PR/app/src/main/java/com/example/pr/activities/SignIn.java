package com.example.pr.activities;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Toast;

import com.example.pr.databinding.ActivitySignInBinding;
import com.example.pr.utilts.Constants;
import com.google.android.gms.auth.api.signin.GoogleSignIn;
import com.google.android.gms.auth.api.signin.GoogleSignInAccount;
import com.google.android.gms.auth.api.signin.GoogleSignInClient;
import com.google.android.gms.auth.api.signin.GoogleSignInOptions;
import com.google.android.gms.common.api.ApiException;
import com.google.android.gms.tasks.Task;
import com.google.firebase.auth.AuthCredential;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.GoogleAuthProvider;
import com.google.firebase.firestore.DocumentReference;
import com.google.firebase.firestore.DocumentSnapshot;
import com.google.firebase.firestore.FirebaseFirestore;

import java.util.Date;
import java.util.HashMap;
import java.util.concurrent.locks.AbstractQueuedSynchronizer;


public class SignIn extends AppCompatActivity {

    private static final int REQUEST_CODE = 100;
    private ActivitySignInBinding binding;

    private GoogleSignInOptions googleSignInOptions;
    private GoogleSignInClient googleSignInClient;
    private GoogleSignInAccount googleSignInAccount;
    private FirebaseAuth firebaseAuth;
    private FirebaseFirestore firebaseFirestore;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivitySignInBinding.inflate(getLayoutInflater());

        firebaseAuth = FirebaseAuth.getInstance();



        firebaseFirestore = FirebaseFirestore.getInstance();
        googleSignInOptions = new GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
                .requestIdToken("218625308856-11putilmmg3idce8url1nvd6n67tlc4v.apps.googleusercontent.com")
                .requestEmail()
                .build();
        googleSignInClient = GoogleSignIn.getClient(this, googleSignInOptions);



        googleSignInAccount = GoogleSignIn.getLastSignedInAccount(this);


        if (googleSignInAccount != null && firebaseAuth.getCurrentUser() != null){
            Auth();
        }

        setContentView(binding.getRoot());

        setListeners();
    }



    private void Auth(){
        loading(true);
        firebaseFirestore.collection(Constants.USERS_COLLECTION)
                .document(firebaseAuth.getCurrentUser().getUid())
                .get().addOnCompleteListener(task -> {
            if (task.isSuccessful()){
                DocumentSnapshot documentSnapshot = task.getResult();
                if (!documentSnapshot.contains(Constants.USER_NAME)){
                    makeToast("Авторизация была провалена, повторите попытку позже");
                }
                else if (documentSnapshot.getString(Constants.USER_ROLE).equals(Constants.USER_ADMIN_ROLE)){
                    Intent intent = new Intent(getApplicationContext(), AdminMainActivity.class);
                    startActivity(intent);
                    finish();
                }
                else if (documentSnapshot.getString(Constants.USER_ROLE).equals(Constants.USER_STUDENT_ROLE)){
                    Intent intent = new Intent(getApplicationContext(), StudentActivity.class);
                    startActivity(intent);
                    finish();
                }
                else if (documentSnapshot.getString(Constants.USER_ROLE).equals(Constants.USER_TEACHER_ROLE)){
                    Intent intent = new Intent(getApplicationContext(), TeacherActivity.class);
                    startActivity(intent);
                    finish();
                }
                else if (documentSnapshot.getString(Constants.USER_ROLE).equals(Constants.USER_NONE_ROLE)){
                    makeToast("Вы успешно создали аккаунт, "
                            + firebaseAuth.getCurrentUser().getDisplayName()
                            + ", ожидайте выдачи роли со стороны администратора");
                    firebaseAuth.signOut();
                    GoogleSignIn.getClient(this, new GoogleSignInOptions
                            .Builder(GoogleSignInOptions.DEFAULT_SIGN_IN).build()).signOut();
                }
            }
            else{
                makeToast("Авторизация была провалена, повторите попытку позже");
            }
        });
        loading(false);
    }

    private void loading(Boolean isLoading){
        if(isLoading){
            binding.buttonSignIn.setVisibility(View.INVISIBLE);
            binding.progressBar.setVisibility(View.VISIBLE);
        }
        else{
            binding.buttonSignIn.setVisibility(View.VISIBLE);
            binding.progressBar.setVisibility(View.INVISIBLE);
        }
    }

    private void setListeners(){
        binding.buttonSignIn.setOnClickListener(v->{
            Intent singIn = googleSignInClient.getSignInIntent();
            startActivityForResult(singIn, REQUEST_CODE);
        });
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        if (requestCode == REQUEST_CODE){
            Task<GoogleSignInAccount> signInTask = GoogleSignIn.getSignedInAccountFromIntent(data);
            try {
                GoogleSignInAccount signInAccount = signInTask.getResult(ApiException.class);
                AuthCredential authCredential = GoogleAuthProvider.getCredential(signInAccount.getIdToken(), null);
                firebaseAuth.signInWithCredential(authCredential).addOnCompleteListener(task -> {
                    if (task.isSuccessful()){
                        firebaseFirestore.collection(Constants.USERS_COLLECTION)
                                .document(firebaseAuth.getCurrentUser().getUid()).get()
                                .addOnCompleteListener(query -> {
                                    if (query.isSuccessful()){
                                        if (!query.getResult().contains(Constants.USER_NAME)){
                                            HashMap<String, Object> user = new HashMap<>();
                                            user.put(Constants.USER_NAME, firebaseAuth.getCurrentUser().getDisplayName());
                                            user.put(Constants.USER_EMAIL, firebaseAuth.getCurrentUser().getEmail());
                                            user.put(Constants.USER_ROLE, Constants.USER_NONE_ROLE);
                                            user.put(Constants.USER_CREATE_DATE, new Date());
                                            user.put(Constants.USER_GROUP, Constants.USER_NONE_GROUP);
                                            firebaseFirestore.collection(Constants.USERS_COLLECTION).
                                                    document(firebaseAuth.getCurrentUser().getUid()).set(user)
                                                    .addOnCompleteListener(task1 -> {
                                                        if (task1.isSuccessful()){
                                                            makeToast("Вы успешно создали аккаунт, "
                                                                    + firebaseAuth.getCurrentUser().getDisplayName()
                                                                    + ", ожидайте выдачи роли со стороны администратора");
                                                        }
                                                        else{
                                                            makeToast("Невозможно создать аккаунт");
                                                        }
                                                    });
                                        }
                                        else{
                                            Auth();
                                        }
                                    }
                                    else{
                                        makeToast("Ошибка при авторизации, попробуйте позже");
                                    }
                                });

                    }
                });
            } catch (ApiException e){
                e.printStackTrace();
            }

        }
    }

    private void makeToast(String message){
        Toast.makeText(this, message, Toast.LENGTH_LONG).show();
    }
}