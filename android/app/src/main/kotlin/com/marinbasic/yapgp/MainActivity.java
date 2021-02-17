package com.marinbasic.yapgp;

import androidx.annotation.NonNull;

import com.google.android.gms.tasks.Tasks;


import org.json.JSONObject;

import java.util.concurrent.Callable;
import java.util.concurrent.Executors;

import crypto.Crypto;
import crypto.Key;
import crypto.UserInfo;
import helper.Helper;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.android.FlutterFragmentActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;


public class MainActivity extends FlutterFragmentActivity {

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor(), "com.marinbasic/gopenpgp").setMethodCallHandler(
                (call, result) -> {
                    Tasks.call(Executors.newSingleThreadExecutor(),(Callable<JSONObject>) () -> {
                        JSONObject resultJSON = new JSONObject();
                        try {
                            switch (call.method) {
                                case "GenerateKey":
                                    int iKeyLength = Integer.parseInt(call.argument("keyLength").toString());
                                    Long keyLength = Long.valueOf(iKeyLength);
                                    Key key = Crypto.generateKey(
                                            call.argument("name"),
                                            call.argument("email"),
                                            call.argument("keyType"),
                                            keyLength
                                    );
                                    String passphrase = call.argument("passphrase");
                                    key = key.lock(passphrase.getBytes());

                                    resultJSON.put("name", call.argument("name"));
                                    resultJSON.put("email", call.argument("email"));
                                    resultJSON.put("passphrase", call.argument("passphrase"));
                                    resultJSON.put("privateKey", key.armor());
                                    resultJSON.put("publicKey", key.getArmoredPublicKey());
                                    resultJSON.put("fingerprint", key.getFingerprint());
                                    resultJSON.put("hexID", key.getHexKeyID());

                                    return resultJSON;
                                case "Encrypt":
                                    String pgpMessage = Helper.encryptSignMessageArmored(
                                            call.argument("pubKey").toString(),
                                            call.argument("privKey").toString(),
                                            call.argument("passphrase").toString().getBytes(),
                                            call.argument("message").toString()
                                    );

                                    resultJSON.put("message", pgpMessage);
                                    return resultJSON;
                                case "EncryptUnsigned":
                                    String unsignedPGPMessage = Helper.encryptMessageArmored(
                                            call.argument("pubKey").toString(),
                                            call.argument("message").toString()
                                    );

                                    resultJSON.put("message", unsignedPGPMessage);
                                    return resultJSON;
                                case "Decrypt":
                                    String message = call.argument("message");

                                    if(!Crypto.isPGPMessage(message)) {
                                        resultJSON.put("error", "This is not a valid PGP message");
                                        return resultJSON;
                                    }
                                    String pass = call.argument("passphrase");
                                    if(pass == null) {
                                        pass = "";
                                    }
                                    String privKey = call.argument("privateKey");

                                    String decrypted = Helper.decryptMessageArmored(privKey, pass.getBytes(), message);
                                    resultJSON.put("message", decrypted);
                                    return resultJSON;
                                case "Identity":
                                    Key pubKey;
                                    UserInfo id;
                                    try{
                                        pubKey = Crypto.newKeyFromArmored(call.argument("pubKey"));
                                        id = pubKey.primaryIdentity();
                                    }catch (Exception e) {
                                        resultJSON.put("error", "Invalid PGP public key");
                                        return resultJSON;
                                    }

                                    resultJSON.put("publicKey", pubKey.getArmoredPublicKey());
                                    resultJSON.put("name", id.getName());
                                    resultJSON.put("email", id.getEmail());
                                    resultJSON.put("fingerprint", pubKey.getFingerprint());
                                    resultJSON.put("hexID", pubKey.getHexKeyID());
                                    return resultJSON;
                                case "Import":
                                    Key privateKey;
                                    UserInfo identity;
                                    String password = call.argument("passphrase");
                                    if(password == null) {
                                        password = "";
                                    }
                                    try {
                                        privateKey = Crypto.newKeyFromArmored(call.argument("privKey"));

                                        if(privateKey.isLocked() && password.isEmpty()) {
                                            resultJSON.put("error", "Private key locked with password");
                                            return resultJSON;
                                        }

                                        if(privateKey.isLocked()) {
                                            privateKey = privateKey.unlock(password.getBytes());
                                            if(privateKey.isLocked()) {
                                                resultJSON.put("error", "Invalid password");
                                                return resultJSON;
                                            }
                                        }

                                        identity = privateKey.primaryIdentity();

                                        resultJSON.put("publicKey", privateKey.getArmoredPublicKey());
                                        resultJSON.put("privateKey", privateKey.armor());
                                        resultJSON.put("name", identity.getName());
                                        resultJSON.put("email", identity.getEmail());
                                        resultJSON.put("fingerprint", privateKey.getFingerprint());
                                        resultJSON.put("hexID", privateKey.getHexKeyID());
                                        return resultJSON;
                                    }catch (Exception e) {
                                        resultJSON.put("error", "Invalid PGP private key or password");
                                        return resultJSON;
                                    }
                                case "Verify":
                                    try {
                                        String msg = Helper.verifyCleartextMessageArmored(
                                                call.argument("pubKey"),
                                                call.argument("message"),
                                                Crypto.getUnixTime()
                                        );
                                        resultJSON.put("msg", msg);
                                    }catch (Exception e) {
                                        resultJSON.put("error", "Contact key does not match PGP signed message");
                                        return resultJSON;
                                    }

                                    return resultJSON;
                                case "Signature":
                                    try {

                                        String msg = Helper.signCleartextMessageArmored(
                                                call.argument("privKey"),
                                                call.argument("passphrase").toString().getBytes(),
                                                call.argument("message")
                                                );
                                        resultJSON.put("msg", msg);
                                        resultJSON.put("time", Crypto.getUnixTime());

                                    }catch (Exception e) {
                                        e.printStackTrace();
                                        resultJSON.put("error", "Cannot create signature");
                                        return resultJSON;
                                    }
                                    return resultJSON;
                            }
                        } catch (Exception e) {
                            resultJSON.put("exception", e.getMessage());
                        }
                        return resultJSON;
                    }).addOnCompleteListener(task -> {
                       if(task.isSuccessful()) {
                           JSONObject res = task.getResult();
                           if(res == null) {
                               res = new JSONObject();
                           }
                           try {
                               if(res.has("error")) {
                                   result.error("logic_error", res.getString("error"), "");
                                   return;
                               }
                               if(res.has("exception")) {
                                   result.error("method_error", res.getString("exception"), "");
                                   return;
                               }
                           }catch (Exception e) {
                               result.error("method_error",e.getMessage(), "");
                               return;
                           }

                           result.success(res.toString());
                       }else {
                           result.error("method_error",task.getException().toString(), "");
                       }
                    });



                }
        );
    }
}
