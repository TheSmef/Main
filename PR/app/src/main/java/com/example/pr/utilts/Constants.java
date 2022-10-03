package com.example.pr.utilts;

import java.util.HashMap;

public class Constants {
    public final static String USERS_COLLECTION = "users";
    public final static String USER_NAME = "name";
    public final static String GROUPS_COLLECTION = "groups";
    public final static String GROUPS_NAME = "name";
    public final static String USER_EMAIL = "email";
    public final static String USER_ROLE = "role";
    public final static String USER_CREATE_DATE = "date_of_creation";
    public final static String USER_GROUP = "group";
    public final static String USER_ADMIN_ROLE = "admin";
    public final static String USER_TEACHER_ROLE = "teacher";
    public final static String USER_STUDENT_ROLE = "student";
    public final static String USER_NONE_ROLE = "none";
    public final static String USER_NONE_GROUP = "none";
    public final static String DEBT_COLLECTION = "debt";
    public final static String DEBT_TEACHER = "teacher_debt";
    public final static String DEBT_STUDENT = "student_debt";
    public final static String DEBT_STUDENT_NAME = "student_debt_name";
    public final static String DEBT_PLACE = "place_debt";
    public final static String TIME_DEBT = "time_debt";
    public final static String DEBT_TIME_CREATION = "time_creation";
    public final static String DEBT_CHECK_STATUS = "check_status";
    public final static String DEBT_GROUP = "group";
    public final static String DEBT_DISCIPLINE = "discipline";
    public final static String KEY_FCM_TOKEN = "fcmToken";
    public static final String REMOTE_MSG_AUTHORIZATION = "Authorization";
    public static final String REMOTE_MSG_CONTENT_TYPE = "Content-Type";
    public static final String REMOTE_MSG_DATA = "data";
    public static final String REMOTE_MSG_REGISTRATION_IDS = "registration_ids";
    public static final String KEY_PREFERENCE_NAME = "preferences";
    public static final String KEY_IS_ACTIVE = "active";


    public static HashMap<String, String> remoteMsgHeader = null;
    public static HashMap<String, String> getRemoteMsgHeader() {
        if(remoteMsgHeader == null){
            remoteMsgHeader = new HashMap<>();
            remoteMsgHeader.put(
                    REMOTE_MSG_AUTHORIZATION,
                    "key=AAAAMucVeLg:APA91bF22dXvIxaY78mSg_MVniQ44g0fF-DaEamgNqPp4J7A32a-ahWX8y8vIYcDLC0iAyHGBq0Ar0eSQcTr4Oi8-_RdqZlgXBm-3ahJgmlWTOx5SDYfIJ2vHX7FUXeS41FjQeHgvo9a"
            );
            remoteMsgHeader.put(
                    REMOTE_MSG_CONTENT_TYPE,
                    "application/json"
            );
        }
        return remoteMsgHeader;
    }
}
