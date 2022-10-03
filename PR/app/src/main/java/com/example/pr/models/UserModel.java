package com.example.pr.models;

import java.io.Serializable;

public class UserModel implements Serializable {
    public String id, name, email, role, date_of_creation, group, token;


    @Override
    public String toString(){
        return this.name;
    }
}
