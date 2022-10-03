package com.example.pr.models;

import java.io.Serializable;

public class GroupModel implements Serializable {
    public String id,name;

    @Override
    public String toString(){
        return this.name;
    }

}
