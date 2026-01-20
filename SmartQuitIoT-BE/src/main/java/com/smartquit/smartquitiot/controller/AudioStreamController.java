package com.smartquit.smartquitiot.controller;

import com.smartquit.smartquitiot.client.AiServiceClient;
import com.smartquit.smartquitiot.dto.request.TextToVoiceRequest;
import feign.Response;
import java.io.InputStream;
import java.util.Base64;
import org.springframework.core.io.InputStreamResource;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class AudioStreamController {

  private final AiServiceClient aiServiceClient;

  public AudioStreamController(AiServiceClient aiServiceClient) {
    this.aiServiceClient = aiServiceClient;
  }

  @GetMapping("/audio-stream")
  public ResponseEntity<?> streamAudio(@RequestParam("text") String base64Text) {
    try {

      String cleanBase64 = base64Text.trim();

      byte[] decodedBytes;
      try {

        decodedBytes = Base64.getUrlDecoder().decode(cleanBase64);
      } catch (IllegalArgumentException e) {

        decodedBytes = Base64.getDecoder().decode(cleanBase64);
      }

      String text = new String(decodedBytes);
      System.out.println("Audio Stream Request for Text: " + text);

      if (text.isEmpty()) {
        return ResponseEntity.badRequest().body("Decoded text is empty");
      }

      // 2. Call Python
      Response feignResponse =
          aiServiceClient.textToVoiceStream(TextToVoiceRequest.builder().text(text).build());

      if (feignResponse.status() != 200) {
        return ResponseEntity.status(feignResponse.status()).build();
      }

      InputStream inputStream = feignResponse.body().asInputStream();

      return ResponseEntity.ok()
          .contentType(MediaType.valueOf("audio/wav"))
          .body(new InputStreamResource(inputStream));

    } catch (Exception e) {
      e.printStackTrace();
      return ResponseEntity.internalServerError().body("Stream Error: " + e.getMessage());
    }
  }
}
