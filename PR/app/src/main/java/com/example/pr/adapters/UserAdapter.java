package com.example.pr.adapters;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Base64;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;


import com.example.pr.databinding.ItemUserBinding;
import com.example.pr.listeners.UserListener;
import com.example.pr.models.UserModel;
import com.example.pr.utilts.Constants;


import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

public class UserAdapter extends RecyclerView.Adapter<UserAdapter.UserViewHolder>{

    public UserAdapter(List<UserModel> users, UserListener userListener) {
        this.userListener = userListener;
        this.users = users;
    }

    private List<UserModel> users;
    private UserListener userListener;

    @NonNull
    @Override
    public UserViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        ItemUserBinding itemContainerUserBinding = ItemUserBinding.inflate(
                LayoutInflater.from(parent.getContext()), parent, false);
        return new UserViewHolder(itemContainerUserBinding);
    }

    @Override
    public void onBindViewHolder(@NonNull UserViewHolder holder, int position) {
        holder.setUserData(users.get(position));
    }



    @Override
    public int getItemCount() {
        return users.size();
    }

    class UserViewHolder extends RecyclerView.ViewHolder {

        ItemUserBinding binding;

        UserViewHolder(ItemUserBinding itemContainerUserBinding) {
            super(itemContainerUserBinding.getRoot());
            binding = itemContainerUserBinding;
        }

        void setUserData(UserModel user){
            binding.textEmail.setText(user.email);
            if (user.group.equals(Constants.USER_NONE_GROUP))
                binding.textGroup.setText("Отсутствует");
            else
                binding.textGroup.setText(user.group);
            binding.textRole.setText(user.role);
            binding.textName.setText(user.name);
            binding.getRoot().setOnClickListener(v->userListener.onUserClicked(user));
            binding.textDateOfCreation.setText(user.date_of_creation);
        }



    }

}
