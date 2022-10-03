package com.example.pr.firebase;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Intent;
import android.os.Build;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.core.app.NotificationManagerCompat;

import com.example.pr.R;
import com.example.pr.activities.SignIn;
import com.example.pr.models.DebtModel;
import com.example.pr.utilts.Constants;
import com.example.pr.utilts.PreferenceManager;
import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;

import java.util.Random;

public class MessagingService extends FirebaseMessagingService {
    @Override
    public void onNewToken(@NonNull String token) {
        super.onNewToken(token);

    }

    @Override
    public void onMessageReceived(@NonNull RemoteMessage remoteMessage) {
        super.onMessageReceived(remoteMessage);

        PreferenceManager preferenceManager = new PreferenceManager(getApplicationContext());
        Boolean status = preferenceManager.getBoolean(Constants.KEY_IS_ACTIVE);

        if (status){
            return;
        }

        DebtModel debt = new DebtModel();
        debt.discipline = remoteMessage.getData().get(Constants.DEBT_DISCIPLINE);

        int notificationId = new Random().nextInt();
        String chanelId = "debt";

        Intent intent = new Intent(this, SignIn.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
        PendingIntent pendingIntent =  PendingIntent.getActivity(this, 0, intent, 0);

        Notification.Builder builder = new Notification.Builder(this, chanelId);
        builder.setSmallIcon(R.drawable.ic_checklist);
        builder.setContentTitle(debt.discipline);
        builder.setContentText("У вас новая задолженность по " + debt.discipline);
        builder.setStyle(new Notification.BigTextStyle().bigText(
                "У вас новая задолженность по " + debt.discipline
        ));
        builder.setPriority(Notification.PRIORITY_DEFAULT);
        builder.setContentIntent(pendingIntent);
        builder.setAutoCancel(true);


        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O){
            CharSequence channelName = "debt";
            String channelDesc = "this notification is used for debt notification";
            int importance = NotificationManager.IMPORTANCE_DEFAULT;
            NotificationChannel channel = new NotificationChannel(chanelId, channelName, importance);
            channel.setDescription(channelDesc);
            NotificationManager notificationManager = getSystemService(NotificationManager.class);
            notificationManager.createNotificationChannel(channel);
        }

        NotificationManagerCompat notificationManagerCompat = NotificationManagerCompat.from(this);
        notificationManagerCompat.notify(notificationId, builder.build());
    }
}
