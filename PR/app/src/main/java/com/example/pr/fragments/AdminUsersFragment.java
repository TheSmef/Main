package com.example.pr.fragments;

import android.app.AlertDialog;
import android.os.Bundle;

import androidx.fragment.app.Fragment;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.Toast;

import com.example.pr.R;
import com.example.pr.adapters.UserAdapter;
import com.example.pr.databinding.ChangeUserPopupBinding;
import com.example.pr.databinding.FragmentAdminUsersBinding;
import com.example.pr.listeners.UserListener;
import com.example.pr.models.GroupModel;
import com.example.pr.models.UserModel;
import com.example.pr.utilts.Constants;
import com.google.firebase.firestore.DocumentChange;
import com.google.firebase.firestore.FirebaseFirestore;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;

public class AdminUsersFragment extends Fragment implements UserListener {

    private FragmentAdminUsersBinding binding;
    private FirebaseFirestore firestore;
    private List<UserModel> users;
    private UserAdapter adapter;
    private AlertDialog.Builder builder;
    private AlertDialog alertDialog;
    List<GroupModel> groups = new ArrayList<>();
    String[] roles = {Constants.USER_NONE_ROLE, Constants.USER_ADMIN_ROLE, Constants.USER_STUDENT_ROLE, Constants.USER_TEACHER_ROLE};

    public static AdminUsersFragment newInstance() {
        AdminUsersFragment fragment = new AdminUsersFragment();
        Bundle args = new Bundle();
        fragment.setArguments(args);
        return fragment;
    }

    public AdminUsersFragment() {

    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setRetainInstance(true);
        binding = FragmentAdminUsersBinding.inflate(getLayoutInflater());
        firestore = FirebaseFirestore.getInstance();
        users = new ArrayList<>();
        setListeners();
        adapter = new UserAdapter(users, this);
        binding.usersRecycler.setAdapter(adapter);


    }

    private void setListeners(){
        firestore.collection(Constants.USERS_COLLECTION).addSnapshotListener((value, error) -> {
            if (error != null){
                return;
            }
            if(value != null){
                int count = users.size();
                for (DocumentChange documentChange : value.getDocumentChanges()) {
                    if (documentChange.getType() == DocumentChange.Type.ADDED) {
                        UserModel user = new UserModel();
                        user.name = documentChange.getDocument().getString(Constants.USER_NAME);
                        user.group = documentChange.getDocument().getString(Constants.USER_GROUP);
                        user.id = documentChange.getDocument().getId();
                        user.role = documentChange.getDocument().getString(Constants.USER_ROLE);
                        user.email = documentChange.getDocument().getString(Constants.USER_EMAIL);
                        user.date_of_creation = getReadableDateTime(documentChange.getDocument().getDate(Constants.USER_CREATE_DATE));
                        users.add(user);
                    }
                    else if (documentChange.getType() == DocumentChange.Type.MODIFIED) {
                        for (int i = 0; i < users.size(); i++) {
                            String id = documentChange.getDocument().getId();
                            if (users.get(i).id.equals(id)) {
                                users.get(i).role = documentChange.getDocument().getString(Constants.USER_ROLE);
                                users.get(i).group = documentChange.getDocument().getString(Constants.USER_GROUP);
                                adapter.notifyItemChanged(i);
                                break;
                            }
                        }
                    }
                    else if (documentChange.getType() == DocumentChange.Type.REMOVED){
                        for (int i = 0; i < users.size(); i++) {
                            String id = documentChange.getDocument().getId();
                            if (users.get(i).id.equals(id)) {
                                users.remove(i);
                                adapter.notifyItemRemoved(i);
                                break;
                            }
                        }
                    }
                }
                Collections.sort(users, (obj1, obj2) -> obj1.date_of_creation.compareTo(obj2.date_of_creation));
                if(count == 0){
                    adapter.notifyDataSetChanged();
                }
                else{
                    adapter.notifyItemRangeChanged(users.size(), users.size());
                }
                binding.usersRecycler.setVisibility(View.VISIBLE);
            }
            binding.progressBar.setVisibility(View.GONE);
        });
        firestore.collection(Constants.GROUPS_COLLECTION).addSnapshotListener((value, error) -> {
            if (error != null){
                return;
            }
            if(value != null){
                for (DocumentChange documentChange : value.getDocumentChanges()) {
                    if (documentChange.getType() == DocumentChange.Type.ADDED) {
                        GroupModel group = new GroupModel();
                        group.id = documentChange.getDocument().getId();
                        group.name = documentChange.getDocument().getString(Constants.GROUPS_NAME);
                        groups.add(group);
                    }
                }
            }
        });
        GroupModel nothing = new GroupModel();
        nothing.id = "nothing";
        nothing.name = "Отсутствует";
        groups.add(nothing);

    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        return binding.getRoot();
    }



    private String getReadableDateTime(Date date){
        return new SimpleDateFormat("dd MMMM, yyyy - hh:mm a", Locale.getDefault()).format(date);
    }

    private void changeUserPopup(UserModel user){
        builder = new AlertDialog.Builder(getContext());
        final View view = getLayoutInflater().inflate(R.layout.change_user_popup, null);
        ChangeUserPopupBinding binding = ChangeUserPopupBinding.bind(view);
        builder.setView(view);
        alertDialog = builder.create();
        binding.userEmail.setText(user.email);
        binding.userName.setText(user.name);
        binding.userDate.setText(user.date_of_creation);
        ArrayAdapter<GroupModel> adapterSpinnerGroups = new ArrayAdapter<>(getContext(), R.layout.spinnertext, groups);
        binding.spinnerGroups.setAdapter(adapterSpinnerGroups);
        for (int i = 0; i < groups.size(); i++) {
            if (groups.get(i).name.equals(user.group))
                binding.spinnerGroups.setSelection(i);
        }
        ArrayAdapter<String> adapterSpinnerRoles = new ArrayAdapter<>(getContext(), R.layout.spinnertext, roles);
        binding.spinnerRoles.setAdapter(adapterSpinnerRoles);
        for (int i = 0; i < roles.length; i++) {
            if (roles[i].equals(user.role))
                binding.spinnerRoles.setSelection(i);
        }
        alertDialog.show();
        binding.buttonConfirm.setOnClickListener(v->{
            HashMap<String, Object> changedUser = new HashMap<>();
            changedUser.put(Constants.USER_GROUP, groups.get(binding.spinnerGroups.getSelectedItemPosition()).name);
            changedUser.put(Constants.USER_ROLE, roles[binding.spinnerRoles.getSelectedItemPosition()]);
            firestore.collection(Constants.USERS_COLLECTION)
                    .document(user.id)
                    .update(changedUser)
                    .addOnCompleteListener(task -> {
                        if (task.isSuccessful()){
                            makeToast("Данные пользователя успешно изменены");
                        }
                        else {
                            makeToast("Ошибка при изменении данных пользователя, попробуйте позже");
                        }
                    });
            alertDialog.dismiss();
        });
        binding.layoutBack.setOnClickListener(v->{
            alertDialog.dismiss();
        });
    }

    @Override
    public void onUserClicked(UserModel user) {
        changeUserPopup(user);
    }




    private void makeToast(String message){
        Toast.makeText(getContext(), message, Toast.LENGTH_LONG).show();
    }
}