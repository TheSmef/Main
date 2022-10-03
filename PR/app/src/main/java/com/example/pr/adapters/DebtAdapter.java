package com.example.pr.adapters;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Base64;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Filter;
import android.widget.Filterable;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;


import com.example.pr.databinding.ItemDebtBinding;
import com.example.pr.databinding.ItemGroupBinding;
import com.example.pr.databinding.ItemUserBinding;
import com.example.pr.listeners.DebtListener;
import com.example.pr.listeners.GroupListener;
import com.example.pr.listeners.UserListener;
import com.example.pr.models.DebtModel;
import com.example.pr.models.GroupModel;
import com.example.pr.models.UserModel;
import com.example.pr.utilts.Constants;


import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

public class DebtAdapter extends RecyclerView.Adapter<DebtAdapter.DebtViewHolder>  {

    public DebtAdapter(List<DebtModel> debts, DebtListener debtListener) {
        this.debts = debts;
        this.debtListener = debtListener;
    }

    private List<DebtModel> debts;
    private DebtListener debtListener;


    @NonNull
    @Override
    public DebtViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        ItemDebtBinding itemContainer = ItemDebtBinding.inflate(
                LayoutInflater.from(parent.getContext()), parent, false);
        return new DebtViewHolder(itemContainer);
    }

    @Override
    public void onBindViewHolder(@NonNull DebtViewHolder holder, int position) {
        holder.setDebtData(debts.get(position));
    }

    @Override
    public int getItemCount() {
        return debts.size();
    }


    class DebtViewHolder extends RecyclerView.ViewHolder {

        ItemDebtBinding binding;

        DebtViewHolder(ItemDebtBinding itemContainer) {
            super(itemContainer.getRoot());
            binding = itemContainer;
        }

        void setDebtData(DebtModel debt){
            binding.textNameTeacher.setText(debt.teacher);
            binding.textTime.setText(debt.time_debt);
            if (debt.checked)
                binding.textStatus.setText("Просмотрено студентом");
            else
                binding.textStatus.setText("Не просмотрено студентом");
            binding.textPlace.setText(debt.place);
            binding.textNameStudent.setText(debt.student);
            binding.textDiscipline.setText(debt.discipline);
            binding.textDateOfCreation.setText(debt.date_of_creation);
            binding.getRoot().setOnClickListener(v->debtListener.onDebtCliked(debt));
        }

    }

}
