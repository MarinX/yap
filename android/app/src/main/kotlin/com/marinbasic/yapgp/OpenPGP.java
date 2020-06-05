package com.marinbasic.yapgp;

import androidx.annotation.NonNull;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

public class OpenPGP implements MethodChannel.MethodCallHandler {

    public static void registerWith(PluginRegistry.Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "gopenpgp");
        channel.setMethodCallHandler(new OpenPGP());
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        switch (call.method) {
            case "test":
                result.success("YEEEEEEEES");
                break;
        }
        result.notImplemented();
    }
}
