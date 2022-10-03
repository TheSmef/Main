package com.example.pr.activities;

import androidx.annotation.NonNull;
import androidx.appcompat.app.ActionBarDrawerToggle;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.view.GravityCompat;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentTransaction;

import android.annotation.SuppressLint;
import android.content.Intent;
import android.os.Bundle;
import android.view.MenuItem;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import com.example.pr.R;
import com.example.pr.databinding.ActivityStudentBinding;
import com.example.pr.databinding.ActivityTeacherBinding;
import com.example.pr.fragments.TeacherGroupsFragment;
import com.example.pr.fragments.UserDebtFragment;
import com.example.pr.models.UserModel;
import com.example.pr.utilts.Constants;
import com.example.pr.utilts.PreferenceManager;
import com.google.android.gms.auth.api.signin.GoogleSignIn;
import com.google.android.gms.auth.api.signin.GoogleSignInOptions;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.firestore.DocumentChange;
import com.google.firebase.firestore.DocumentReference;
import com.google.firebase.firestore.FieldValue;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.messaging.FirebaseMessaging;
import com.makeramen.roundedimageview.RoundedImageView;
import com.squareup.picasso.Picasso;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Locale;

public class StudentActivity extends AppCompatActivity {

    private ActivityStudentBinding binding;
    private ActionBarDrawerToggle actionBarDrawerToggle;
    private FirebaseAuth auth;
    private FirebaseFirestore firestore;
    private UserModel user;

    @Override
    protected void onPause() {
        super.onPause();
        PreferenceManager preferenceManager = new PreferenceManager(getApplicationContext());
        preferenceManager.putBoolean(Constants.KEY_IS_ACTIVE, false);
    }

    @Override
    protected void onResume() {
        super.onResume();
        PreferenceManager preferenceManager = new PreferenceManager(getApplicationContext());
        preferenceManager.putBoolean(Constants.KEY_IS_ACTIVE, true);
    }

    @Override
    protected void onStop() {
        super.onStop();
        PreferenceManager preferenceManager = new PreferenceManager(getApplicationContext());
        preferenceManager.putBoolean(Constants.KEY_IS_ACTIVE, false);
    }

    @Override
    protected void onStart() {
        super.onStart();
        PreferenceManager preferenceManager = new PreferenceManager(getApplicationContext());
        preferenceManager.putBoolean(Constants.KEY_IS_ACTIVE, true);
    }

    @Override
    public boolean onOptionsItemSelected(@NonNull MenuItem item) {
        if (actionBarDrawerToggle.onOptionsItemSelected(item)){
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    @Override
    protected void onSaveInstanceState(@NonNull Bundle outState) {
        super.onSaveInstanceState(outState);
    }

    @Override
    protected void onRestoreInstanceState(@NonNull Bundle savedInstanceState) {
        super.onRestoreInstanceState(savedInstanceState);
    }

    @SuppressLint("NonConstantResourceId")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        PreferenceManager preferenceManager = new PreferenceManager(getApplicationContext());
        preferenceManager.putBoolean(Constants.KEY_IS_ACTIVE, true);
        firestore = FirebaseFirestore.getInstance();
        auth = FirebaseAuth.getInstance();
        binding = ActivityStudentBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());
        actionBarDrawerToggle =
                new ActionBarDrawerToggle(this, binding.drawerLayout, R.string.Open, R.string.Close);
        binding.drawerLayout.addDrawerListener(actionBarDrawerToggle);
        actionBarDrawerToggle.syncState();
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        user = new UserModel();
        View navView = binding.navView.getHeaderView(0);
        firestore.collection(Constants.USERS_COLLECTION).document(auth.getCurrentUser().getUid())
                .get().addOnCompleteListener(task -> {
                        if(task.isSuccessful()){
                            user.id = task.getResult().getId();
                            user.name = task.getResult().getString(Constants.USER_NAME);
                            user.email = task.getResult().getString(Constants.USER_EMAIL);
                            user.role = task.getResult().getString(Constants.USER_ROLE);
                            user.email = task.getResult().getString(Constants.USER_EMAIL);
                            user.date_of_creation = getReadableDateTime(task.getResult().getDate(Constants.USER_CREATE_DATE));
                            user.group = task.getResult().getString(Constants.USER_GROUP);
                            getToken();
                            replaceFragment(new UserDebtFragment(user));
                            binding.navView.setNavigationItemSelectedListener(item -> {
                                switch (item.getItemId()){
                                    case R.id.nav_debts:
                                        replaceFragment(new UserDebtFragment(user));
                                        binding.drawerLayout.closeDrawer(GravityCompat.START);
                                        return true;
                                    case R.id.nav_exit:
                                        GoogleSignIn.getClient(this, new GoogleSignInOptions
                                                .Builder(GoogleSignInOptions.DEFAULT_SIGN_IN).build()).signOut()
                                                .addOnCompleteListener(t -> {
                                                    if (t.isSuccessful()) {
                                                        DocumentReference documentReference =
                                                                firestore.collection(Constants.USERS_COLLECTION).document(
                                                                        user.id
                                                                );
                                                        HashMap<String, Object> updates = new HashMap<>();
                                                        updates.put(Constants.KEY_FCM_TOKEN, FieldValue.delete());
                                                        documentReference.update(updates).addOnSuccessListener(unused -> {
                                                            auth.signOut();
                                                            startActivity(new Intent(getApplicationContext(), SignIn.class));
                                                            finish();
                                                        }).addOnFailureListener(e -> makeToast("Невозможно выйти из аккаунта в данный момент, попробуйте позже"));
                                                    }
                                                    else
                                                        makeToast("Невозможно выйти из аккаунта в данный момент, попробуйте позже");
                                                });
                                        binding.drawerLayout.closeDrawer(GravityCompat.START);
                                        return true;
                                }


                                return false;
                            });
                        }
        });
        RoundedImageView profileImage =  navView.findViewById(R.id.profileImage);
        TextView profileEmail = navView.findViewById(R.id.profileEmail);
        TextView profileName = navView.findViewById(R.id.profileName);
        if (auth.getCurrentUser().getPhotoUrl() != null)
            Picasso.get().load(auth.getCurrentUser().getPhotoUrl())
                    .into(profileImage);
        else
            profileImage.setImageResource(R.drawable.ic_users);

        profileEmail.setText(auth.getCurrentUser().getEmail());
        profileName.setText(auth.getCurrentUser().getDisplayName());



    }

    private void getToken(){
        FirebaseMessaging.getInstance().getToken().addOnSuccessListener(this::updateToken);
    }

    private void updateToken(String token){
                firestore.collection(Constants.USERS_COLLECTION).document(
                        user.id
                ).update(Constants.KEY_FCM_TOKEN, token);
    }
    private void makeToast(String message){
        Toast.makeText(this, message, Toast.LENGTH_LONG).show();
    }

    private String getReadableDateTime(Date date){
        return new SimpleDateFormat("dd MMMM, yyyy - hh:mm a", Locale.getDefault()).format(date);
    }

    public void replaceFragment(Fragment fragment){
        FragmentManager fragmentManager = getSupportFragmentManager();
        FragmentTransaction transaction = fragmentManager.beginTransaction();
        transaction.replace(binding.frameLayout.getId(), fragment);
        transaction.commit();
    }
}