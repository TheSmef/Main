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


import com.example.pr.databinding.ItemGroupBinding;
import com.example.pr.databinding.ItemUserBinding;
import com.example.pr.listeners.GroupListener;
import com.example.pr.listeners.UserListener;
import com.example.pr.models.GroupModel;
import com.example.pr.models.UserModel;
import com.example.pr.utilts.Constants;


import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

public class GroupAdapter extends RecyclerView.Adapter<GroupAdapter.GroupsViewHolder>  {

    public GroupAdapter(List<GroupModel> groups, GroupListener groupListener) {
        this.groups = groups;
        this.groupListener = groupListener;
    }

    private List<GroupModel> groups;
    private GroupListener groupListener;


    @NonNull
    @Override
    public GroupsViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        ItemGroupBinding itemContainer = ItemGroupBinding.inflate(
                LayoutInflater.from(parent.getContext()), parent, false);
        return new GroupsViewHolder(itemContainer);
    }

    @Override
    public void onBindViewHolder(@NonNull GroupsViewHolder holder, int position) {
        holder.setGroupData(groups.get(position));
    }

    @Override
    public int getItemCount() {
        return groups.size();
    }


    class GroupsViewHolder extends RecyclerView.ViewHolder {

        ItemGroupBinding binding;

        GroupsViewHolder(ItemGroupBinding itemContainer) {
            super(itemContainer.getRoot());
            binding = itemContainer;
        }

        void setGroupData(GroupModel group){
            binding.textNameGroup.setText(group.name);
            binding.getRoot().setOnClickListener(v->groupListener.onGroupClicked(group));
        }

    }

}
