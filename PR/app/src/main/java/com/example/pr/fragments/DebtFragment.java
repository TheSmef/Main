package com.example.pr.fragments;

import android.app.AlertDialog;
import android.os.Bundle;

import androidx.annotation.NonNull;
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
import com.example.pr.databinding.NewPopupDebtBinding;
import com.example.pr.listeners.DebtListener;
import com.example.pr.listeners.UserListener;
import com.example.pr.models.DebtModel;
import com.example.pr.models.GroupModel;
import com.example.pr.models.UserModel;
import com.example.pr.network.ApiClient;
import com.example.pr.network.ApiService;
import com.example.pr.utilts.Constants;
import com.google.firebase.firestore.DocumentChange;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.QueryDocumentSnapshot;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Objects;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;


public class DebtFragment extends Fragment implements UserListener, DebtListener {

    private FragmentAdminDebtBinding binding;
    private GroupModel targetGroup;
    private FirebaseFirestore firestore;
    private List<DebtModel> debts;
    private List<UserModel> users;
    private AlertDialog.Builder builder;
    private AlertDialog alertDialog;
    private List<UserModel> debtUsers;
    private UsersDebtAdapter usersDebtAdapter;
    private DebtAdapter adapter;

    public DebtFragment(GroupModel group) {
        targetGroup = group;
    }

    public DebtFragment() {
        // Required empty public constructor
    }


    public static DebtFragment newInstance(String param1, String param2) {
        DebtFragment fragment = new DebtFragment();
        Bundle args = new Bundle();
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = FragmentAdminDebtBinding.inflate(getLayoutInflater());
        firestore = FirebaseFirestore.getInstance();
        users = new ArrayList<>();
        debts = new ArrayList<>();
        adapter = new DebtAdapter(debts, this);
        binding.debtRecycler.setAdapter(adapter);
        setListeners();

    }

    private void setListeners(){
        firestore.collection(Constants.DEBT_COLLECTION)
                .whereEqualTo(Constants.DEBT_GROUP, targetGroup.name)
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
        firestore.collection(Constants.USERS_COLLECTION)
                .whereEqualTo(Constants.USER_GROUP, targetGroup.name)
                .whereEqualTo(Constants.USER_ROLE, Constants.USER_STUDENT_ROLE)
                .addSnapshotListener((value, error) -> {
                    if (error != null){
                        return;
                    }
                    if(value != null){
                        for (DocumentChange documentChange : value.getDocumentChanges()) {
                            if (documentChange.getType() == DocumentChange.Type.ADDED) {
                                UserModel user = new UserModel();
                                user.name = documentChange.getDocument().getString(Constants.USER_NAME);
                                user.group = documentChange.getDocument().getString(Constants.USER_GROUP);
                                user.id = documentChange.getDocument().getId();
                                user.role = documentChange.getDocument().getString(Constants.USER_ROLE);
                                user.email = documentChange.getDocument().getString(Constants.USER_EMAIL);
                                user.date_of_creation = getReadableDateTime(documentChange.getDocument().getDate(Constants.USER_CREATE_DATE));
                                user.token = documentChange.getDocument().getString(Constants.KEY_FCM_TOKEN);
                                users.add(user);
                            }
                        }

                    }
                });
        binding.buttonAddDebt.setOnClickListener(view -> createNewDebt());
        binding.buttonDeleteDebts.setOnClickListener( view -> deleteDebts());

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

    private void createNewDebt(){
        builder = new AlertDialog.Builder(getContext());
        final View view = getLayoutInflater().inflate(R.layout.new_popup_debt, null);
        debtUsers = new ArrayList<>();
        NewPopupDebtBinding binding = NewPopupDebtBinding.bind(view);
        usersDebtAdapter = new UsersDebtAdapter(debtUsers, this);
        builder.setView(view);
        alertDialog = builder.create();
        alertDialog.show();
        ArrayAdapter<UserModel> adapterSpinner = new ArrayAdapter<>(getContext(), R.layout.spinnertext, users);
        binding.studentsRecycler.setAdapter(usersDebtAdapter);
        binding.spinnerStudents.setAdapter(adapterSpinner);
        binding.buttonAddStudent.setOnClickListener(v -> {
            if (binding.spinnerStudents.getSelectedItem() != null){
                for (int i = 0; i < debtUsers.size(); i++){
                    if (debtUsers.get(i) == users.get(binding.spinnerStudents.getSelectedItemPosition()))
                        return;
                }
                debtUsers.add(users.get(binding.spinnerStudents.getSelectedItemPosition()));
                usersDebtAdapter.notifyDataSetChanged();
            }
        });
        binding.layoutBack.setOnClickListener(v -> {
            alertDialog.dismiss();
        });
        binding.buttonConfirm.setOnClickListener(v -> {
            if (binding.cabText.getText().toString().isEmpty()
                    || binding.timeText.getText().toString().isEmpty()
                    || binding.teacherText.getText().toString().isEmpty()
                    || binding.discipline.getText().toString().isEmpty()){
                makeToast("Заполните все поля при вводе задолжности");
                return;
            }
            for (UserModel user: debtUsers) {
                HashMap<String, Object> debt = new HashMap<>();
                debt.put(Constants.DEBT_PLACE, binding.cabText.getText().toString());
                debt.put(Constants.TIME_DEBT, binding.timeText.getText().toString());
                debt.put(Constants.DEBT_STUDENT, user.id);
                debt.put(Constants.DEBT_TEACHER, binding.teacherText.getText().toString());
                debt.put(Constants.DEBT_GROUP, targetGroup.name);
                debt.put(Constants.DEBT_TIME_CREATION, new Date());
                debt.put(Constants.DEBT_CHECK_STATUS, false);
                debt.put(Constants.DEBT_DISCIPLINE, binding.discipline.getText().toString());
                debt.put(Constants.DEBT_STUDENT_NAME, user.name);
                firestore.collection(Constants.DEBT_COLLECTION).add(debt);

                try {
                    if (!user.token.equals("")) {
                        JSONArray tokens = new JSONArray();
                        tokens.put(user.token);

                        JSONObject data = new JSONObject();
                        data.put(Constants.DEBT_DISCIPLINE, binding.discipline.getText().toString());

                        JSONObject body = new JSONObject();
                        body.put(Constants.REMOTE_MSG_DATA, data);
                        body.put(Constants.REMOTE_MSG_REGISTRATION_IDS, tokens);

                        sendNotification(body.toString());
                    }
                }
                catch (Exception e){

                }

            }
            alertDialog.dismiss();
        });
    }

    @Override
    public void onUserClicked(UserModel user) {
        for (int i = 0; i < users.size(); i++){
            if (users.get(i).id.equals(user.id)){
                debtUsers.remove(i);
                usersDebtAdapter.notifyItemRemoved(i);
            }
        }
    }

    private void deleteDebts() {
        builder = new AlertDialog.Builder(getContext());
        final View view = getLayoutInflater().inflate(R.layout.bool_dialog, null);
        BoolDialogBinding binding = BoolDialogBinding.bind(view);
        builder.setView(view);
        alertDialog = builder.create();
        alertDialog.show();
        binding.text.setText("Вы уверены, что хотите удалить все задолжности данной группы?");
        binding.buttonConfirm.setOnClickListener( v -> {
            firestore.collection(Constants.DEBT_COLLECTION)
                    .whereEqualTo(Constants.DEBT_GROUP, targetGroup.name).get()
            .addOnCompleteListener( task -> {
                if(task.isSuccessful() && task.getResult() != null){
                    for(QueryDocumentSnapshot documentSnapshot : task.getResult()){
                        firestore.collection(Constants.DEBT_COLLECTION)
                                .document(documentSnapshot.getId())
                                .delete();
                    }
                }
            });
            alertDialog.dismiss();
        });
        binding.buttonCancel.setOnClickListener( v -> {
            alertDialog.dismiss();
        });
        binding.layoutBack.setOnClickListener( v->{
            alertDialog.dismiss();
        });
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
        binding.buttonDelete.setOnClickListener( v -> {
            firestore.collection(Constants.DEBT_COLLECTION)
                    .document(debt.id)
                    .delete().addOnCompleteListener(task -> {
                        if (task.isSuccessful()){
                            makeToast("Задолжность успешно удалена");
                        }
                        else{
                            makeToast("Ошибка при удалении задоджности");
                        }
                        alertDialog.dismiss();
            });
        });
    }




    private void makeToast(String message){
        Toast.makeText(getContext(), message, Toast.LENGTH_LONG).show();
    }

    private void sendNotification(String messageBody){
        ApiClient.getClient().create(ApiService.class).sendMessage(
                Constants.getRemoteMsgHeader(),
                messageBody
        ).enqueue(new Callback<String>() {
            @Override
            public void onResponse(@NonNull Call<String> call, @NonNull Response<String> response) {
                if (response.isSuccessful()){
                    try {
                        if (response.body() != null){
                            JSONObject responseJson = new JSONObject(response.body());
                            JSONArray results = responseJson.getJSONArray("results");
                            if (responseJson.getInt("failure") == 1){
                                return;
                            }
                        }
                    }
                    catch (JSONException e){
                        e.printStackTrace();
                    }

                }
            }

            @Override
            public void onFailure(@NonNull Call<String> call, @NonNull Throwable t) {
                makeToast(t.getMessage());
            }
        });
    }
}