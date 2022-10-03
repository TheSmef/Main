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
import com.example.pr.adapters.DebtAdapter;
import com.example.pr.adapters.UsersDebtAdapter;
import com.example.pr.databinding.BoolDialogBinding;
import com.example.pr.databinding.ChangeDebtPopupBinding;
import com.example.pr.databinding.FragmentAdminDebtBinding;
import com.example.pr.databinding.FragmentUserDebtBinding;
import com.example.pr.databinding.NewPopupDebtBinding;
import com.example.pr.listeners.DebtListener;
import com.example.pr.models.DebtModel;
import com.example.pr.models.GroupModel;
import com.example.pr.models.UserModel;
import com.example.pr.utilts.Constants;
import com.google.firebase.firestore.DocumentChange;
import com.google.firebase.firestore.DocumentReference;
import com.google.firebase.firestore.DocumentSnapshot;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.QueryDocumentSnapshot;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Objects;


public class UserDebtFragment extends Fragment implements DebtListener {

    private FragmentUserDebtBinding binding;
    private UserModel targetUser;
    private FirebaseFirestore firestore;
    private List<DebtModel> debts;
    private AlertDialog.Builder builder;
    private AlertDialog alertDialog;
    private DebtAdapter adapter;

    public UserDebtFragment(UserModel user) {
        targetUser = user;
    }

    public UserDebtFragment() {
        // Required empty public constructor
    }


    public static UserDebtFragment newInstance(String param1, String param2) {
        UserDebtFragment fragment = new UserDebtFragment();
        Bundle args = new Bundle();
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = FragmentUserDebtBinding.inflate(getLayoutInflater());
        firestore = FirebaseFirestore.getInstance();
        debts = new ArrayList<>();
        adapter = new DebtAdapter(debts, this);
        binding.debtRecycler.setAdapter(adapter);
        setListeners();

    }

    private void setListeners(){
        firestore.collection(Constants.DEBT_COLLECTION)
                .whereEqualTo(Constants.DEBT_GROUP, targetUser.group)
                .whereEqualTo(Constants.DEBT_STUDENT, targetUser.id)
                .addSnapshotListener((value, error) -> {
                    if (error != null){
                        return;
                    }
                    if(value != null){
                        int count = debts.size();
                        for (DocumentChange documentChange : value.getDocumentChanges()) {
                            if (documentChange.getType() == DocumentChange.Type.ADDED) {
                                DebtModel debt = new DebtModel();
                                debt.id = documentChange.getDocument().getId();
                                debt.checked = documentChange.getDocument()
                                        .getBoolean(Constants.DEBT_CHECK_STATUS);
                                debt.time_debt = documentChange.getDocument()
                                        .getString(Constants.TIME_DEBT);
                                debt.date_of_creation = getReadableDateTime(documentChange.getDocument()
                                        .getDate(Constants.DEBT_TIME_CREATION));
                                debt.discipline = documentChange.getDocument()
                                        .getString(Constants.DEBT_DISCIPLINE);
                                debt.place = documentChange.getDocument()
                                        .getString(Constants.DEBT_PLACE);
                                debt.group = documentChange.getDocument()
                                        .getString(Constants.DEBT_GROUP);
                                debt.teacher = documentChange.getDocument()
                                        .getString(Constants.DEBT_TEACHER);
                                firestore.collection(Constants.USERS_COLLECTION)
                                        .document(Objects.requireNonNull(documentChange.getDocument()
                                                .getString(Constants.DEBT_STUDENT))).get()
                                        .addOnCompleteListener(task -> {
                                            if (task.isSuccessful()){
                                                debt.student_id = task.getResult().getString(Constants.USER_NAME);
                                            }
                                        });
                                debt.student = documentChange.getDocument().getString(Constants.DEBT_STUDENT_NAME);
                                debts.add(debt);
                                firestore.collection(Constants.DEBT_COLLECTION)
                                        .document(documentChange.getDocument().getId())
                                        .update(Constants.DEBT_CHECK_STATUS, true);
                            }
                            else if (documentChange.getType() == DocumentChange.Type.REMOVED){
                                for (int i = 0; i < debts.size(); i++) {
                                    String id = documentChange.getDocument().getId();
                                    if (debts.get(i).id.equals(id)) {
                                        debts.remove(i);
                                        adapter.notifyItemRemoved(i);
                                        break;
                                    }
                                }
                            }
                            else if(documentChange.getType() == DocumentChange.Type.MODIFIED){
                                for (int i = 0; i < debts.size(); i++) {
                                    String id = documentChange.getDocument().getId();
                                    if (debts.get(i).id.equals(id)) {
                                        debts.get(i).checked = documentChange.getDocument()
                                                .getBoolean(Constants.DEBT_CHECK_STATUS);
                                        adapter.notifyItemChanged(i);
                                        break;
                                    }
                                }
                            }
                        }
                        if(count == 0){
                            adapter.notifyDataSetChanged();
                        }
                        else{
                            adapter.notifyItemRangeChanged(debts.size(), debts.size());
                        }
                        binding.debtRecycler.setVisibility(View.VISIBLE);
                    }
                    binding.progressBar.setVisibility(View.GONE);
                });

    }

    private String getReadableDateTime(Date date){
        return new SimpleDateFormat("dd MMMM, yyyy - hh:mm a", Locale.getDefault()).format(date);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        return binding.getRoot();
    }




    @Override
    public void onDebtCliked(DebtModel debt) {
        builder = new AlertDialog.Builder(getContext());
        final View view = getLayoutInflater().inflate(R.layout.change_debt_popup, null);
        ChangeDebtPopupBinding binding = ChangeDebtPopupBinding.bind(view);
        builder.setView(view);
        alertDialog = builder.create();
        alertDialog.show();
        binding.cabText.setText(debt.place);
        binding.discipline.setText(debt.discipline);
        binding.groupText.setText(debt.group);
        binding.timeCreation.setText(debt.date_of_creation);
        binding.timeDebt.setText(debt.time_debt);
        binding.studentName.setText(debt.student);
        binding.teacherText.setText(debt.teacher);
        if (debt.checked)
            binding.checkStatus.setText("Просмотрено студентом");
        else
            binding.checkStatus.setText("Не просмотрено студентом");
        binding.layoutBack.setOnClickListener( v -> {
            alertDialog.dismiss();
        });
        binding.buttonDelete.setVisibility(View.GONE);
    }




    private void makeToast(String message){
        Toast.makeText(getContext(), message, Toast.LENGTH_LONG).show();
    }
}