package com.example.chat.adapters;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;

import android.util.Base64;
import android.view.LayoutInflater;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.example.chat.databinding.ItemContainerRecentConvBinding;
import com.example.chat.listeners.ConvListener;
import com.example.chat.models.ChatMessage;
import com.example.chat.models.User;

import java.util.List;

public class RecentConvAdapter extends RecyclerView.Adapter<RecentConvAdapter.ConvViewHolder>{

    private final List<ChatMessage> chatMessages;
    private final ConvListener convListener;

    public RecentConvAdapter(List<ChatMessage> chatMessages, ConvListener convListener) {
        this.chatMessages = chatMessages;
        this.convListener = convListener;
    }

    @NonNull
    @Override
    public ConvViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new ConvViewHolder(
                ItemContainerRecentConvBinding.inflate(LayoutInflater.from(parent.getContext()),
                parent,
                false
        ));
    }

    @Override
    public void onBindViewHolder(@NonNull ConvViewHolder holder, int position) {
        holder.setData(chatMessages.get(position));
    }

    @Override
    public int getItemCount() {
        return chatMessages.size();
    }

    class ConvViewHolder extends RecyclerView.ViewHolder {

        ItemContainerRecentConvBinding binding;

        ConvViewHolder(ItemContainerRecentConvBinding binding){
            super(binding.getRoot());
            this.binding = binding;
        }

        void setData(ChatMessage chatMessage){
            binding.imageProfile.setImageBitmap(getConvImage(chatMessage.convImage));
            binding.textName.setText(chatMessage.convName);
            binding.textRecentMessage.setText(chatMessage.message);
            binding.textDateTime.setText(chatMessage.dateTime);
            binding.getRoot().setOnClickListener(v -> {
                User user = new User();
                user.id = chatMessage.convID;
                user.name = chatMessage.convName;
                user.image = chatMessage.convImage;
                convListener.onConvClicked(user);
            });
        }
    }

    private Bitmap getConvImage(String encodedImage){
        byte[] bytes = Base64.decode(encodedImage, Base64.DEFAULT);
        return  BitmapFactory.decodeByteArray(bytes, 0, bytes.length);
    }

}
