package clavision;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class UserManager {
    void initial() {
        (new UserDAO()).createTable();
    }

    static public User logInWithAccessToken(String accessToken) {
        try {
            final byte[] accessTokenHash = MessageDigest.getInstance("SHA-256").digest(accessToken.getBytes());
            return UserDAO.getByAccessTokenHash(accessTokenHash);

        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
        }
        return null;
    }

    static public User logInWithLineCode(String  code) {
        return UserDAO.getByLineId(code);
    }

}
