package com.example.pr.fragments;

import android.app.AlertDialog;
import android.os.Bundle;

import androidx.fragment.app.Fragment;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Toast;

import com.example.pr.R;
import com.example.pr.activities.AdminMainActivity;
import com.example.pr.activities.TeacherActivity;
import com.example.pr.adapters.GroupAdapter;
import com.example.pr.databinding.ChangeGroupPopupBinding;
import com.example.pr.databinding.FragmentAdminGroupsBinding;
import com.example.pr.databinding.FragmentTeacherGroupsBinding;
import com.example.pr.databinding.NewGroupPopupBinding;
import com.example.pr.listeners.GroupListener;
import com.example.pr.models.GroupModel;
import com.example.pr.utilts.Constants;
import com.google.firebase.firestore.DocumentChange;
import com.google.firebase.firestore.FirebaseFirestore;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;


public class TeacherGroupsFragment extends Fragment implements GroupListener {

    private FragmentTeacherGroupsBinding binding;
    private List<GroupModel> groups;
    private FirebaseFirestore firestore;
    private GroupAdapter adapter;
    private AlertDialog.Builder builder;
    private AlertDialog alertDialog;
    private TeacherActivity parent;

    public TeacherGroupsFragment() {
        // Required empty public constructor

    }


    public TeacherGroupsFragment(TeacherActivity teacherActivity) {
        parent = teacherActivity;
    }

    public static AdminGroupsFragment newInstance() {
        AdminGroupsFragment fragment = new AdminGroupsFragment();
        Bundle args = new Bundle();
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setRetainInstance(true);
        binding = FragmentTeacherGroupsBinding.inflate(getLayoutInflater());
        firestore = FirebaseFirestore.getInstance();
        groups = new ArrayList<>();
        adapter = new GroupAdapter(groups, this);
        binding.groupsRecycler.setAdapter(adapter);
        setListeners();
    }

    private void setListeners(){
        firestore.collection(Constants.GROUPS_COLLECTION).addSnapshotListener((value, error) -> {
            if (error != null){
                return;
            }
            if(value != null){
                int count = groups.size();
                for (DocumentChange documentChange : value.getDocumentChanges()) {
                    if (documentChange.getType() == DocumentChange.Type.ADDED) {
                        GroupModel group = new GroupModel();
                        group.id = documentChange.getDocument().getId();
                        group.name = documentChange.getDocument().getString(Constants.GROUPS_NAME);
                        groups.add(group);
                    }
                    else if (documentChange.getType() == DocumentChange.Type.REMOVED){
                        for (int i = 0; i < groups.size(); i++) {
                            String id = documentChange.getDocument().getId();
                            if (groups.get(i).id.equals(id)) {
                                groups.remove(i);
                                adapter.notifyItemRemoved(i);
                                break;
                            }
                        }
                    }
                }
                if(count == 0){
                    adapter.notifyDataSetChanged();
                }
                else{
                    adapter.notifyItemRangeChanged(groups.size(), groups.size());
                }
                binding.groupsRecycler.setVisibility(View.VISIBLE);
            }
            binding.progressBar.setVisibility(View.GONE);
        });
    }


    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        return binding.getRoot();
    }

    private void loading(Boolean isLoading){
        if (isLoading){
            binding.progressBar.setVisibility(View.VISIBLE);
            binding.groupsRecycler.setVisibility(View.GONE);
        }
        else{
            binding.progressBar.setVisibility(View.GONE);
            binding.groupsRecycler.setVisibility(View.VISIBLE);
        }
    }

    @Override
    public void onGroupClicked(GroupModel group) {
        parent.replaceFragment(new DebtFragment(group));
    }



    private void makeToast(String message){
        Toast.makeText(getContext(), message, Toast.LENGTH_LONG).show();
    }
}