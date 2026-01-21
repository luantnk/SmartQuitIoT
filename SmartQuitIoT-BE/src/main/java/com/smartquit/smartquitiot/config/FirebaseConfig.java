package com.smartquit.smartquitiot.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import jakarta.annotation.PostConstruct;
import java.io.IOException;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.ClassPathResource;

@Configuration
public class FirebaseConfig {
  @PostConstruct
  public void init() throws IOException {
    FirebaseOptions options =
        FirebaseOptions.builder()
            .setCredentials(
                GoogleCredentials.fromStream(
                    new ClassPathResource("serviceAccountKey.json").getInputStream()))
            .build();
    if (FirebaseApp.getApps().isEmpty()) {
      FirebaseApp.initializeApp(options);
    }
  }
}
