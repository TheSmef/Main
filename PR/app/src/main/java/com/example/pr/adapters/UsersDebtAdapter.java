package com.example.pr.adapters;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Base64;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;


import com.example.pr.databinding.ItemDebtuserBinding;
import com.example.pr.databinding.ItemUserBinding;
import com.example.pr.listeners.UserListener;
import com.example.pr.models.UserModel;
import com.example.pr.utilts.Constants;


import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

public class UsersDebtAdapter extends RecyclerView.Adapter<UsersDebtAdapter.UserViewHolder>{

    public UsersDebtAdapter(List<UserModel> users, UserListener userListener) {
        this.userListener = userListener;
        this.users = users;
    }

    private List<UserModel> users;
    private UserListener userListener;

    @NonNull
    @Override
    public UserViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        ItemDebtuserBinding itemContainerUserBinding = ItemDebtuserBinding.inflate(
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

        ItemDebtuserBinding binding;

        UserViewHolder(ItemDebtuserBinding itemContainerUserBinding) {
            super(itemContainerUserBinding.getRoot());
            binding = itemContainerUserBinding;
        }

        void setUserData(UserModel user){
            binding.textName.setText(user.name);
            binding.layoutDelete.setOnClickListener(view -> userListener.onUserClicked(user));
        }
    }

}
