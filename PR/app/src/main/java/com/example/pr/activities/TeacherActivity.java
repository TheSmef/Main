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
import com.example.pr.databinding.ActivityAdminMainBinding;
import com.example.pr.databinding.ActivityTeacherBinding;
import com.example.pr.fragments.AdminGroupsFragment;
import com.example.pr.fragments.AdminUsersFragment;
import com.example.pr.fragments.TeacherGroupsFragment;
import com.google.android.gms.auth.api.signin.GoogleSignIn;
import com.google.android.gms.auth.api.signin.GoogleSignInOptions;
import com.google.firebase.auth.FirebaseAuth;
import com.makeramen.roundedimageview.RoundedImageView;
import com.squareup.picasso.Picasso;

public class TeacherActivity extends AppCompatActivity {

    private ActivityTeacherBinding binding;
    private ActionBarDrawerToggle actionBarDrawerToggle;
    private FirebaseAuth auth;

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
        auth = FirebaseAuth.getInstance();
        binding = ActivityTeacherBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());
        actionBarDrawerToggle =
                new ActionBarDrawerToggle(this, binding.drawerLayout, R.string.Open, R.string.Close);
        binding.drawerLayout.addDrawerListener(actionBarDrawerToggle);
        actionBarDrawerToggle.syncState();
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        replaceFragment(new TeacherGroupsFragment(this));
        View navView = binding.navView.getHeaderView(0);

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

        binding.navView.setNavigationItemSelectedListener(item -> {
            switch (item.getItemId()){
                case R.id.nav_groups:
                    replaceFragment(new TeacherGroupsFragment(this));
                    binding.drawerLayout.closeDrawer(GravityCompat.START);
                    break;
                case R.id.nav_exit:
                    auth.signOut();
                    GoogleSignIn.getClient(this, new GoogleSignInOptions
                            .Builder(GoogleSignInOptions.DEFAULT_SIGN_IN).build()).signOut()
                            .addOnCompleteListener(task -> {
                                if (task.isSuccessful()) {
                                    startActivity(new Intent(this, SignIn.class));
                                    finish();
                                }
                                else
                                    makeToast("Невозможно выйти из аккаунта в данный момент, попробуйте позже");
                            });
                    binding.drawerLayout.closeDrawer(GravityCompat.START);
                    break;
            }

            return true;
        });
    }
    private void makeToast(String message){
        Toast.makeText(this, message, Toast.LENGTH_LONG).show();
    }

    public void replaceFragment(Fragment fragment){
        FragmentManager fragmentManager = getSupportFragmentManager();
        FragmentTransaction transaction = fragmentManager.beginTransaction();
        transaction.replace(binding.frameLayout.getId(), fragment);
        transaction.commit();
    }
}