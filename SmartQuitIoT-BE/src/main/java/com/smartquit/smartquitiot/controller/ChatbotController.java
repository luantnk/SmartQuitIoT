package com.smartquit.smartquitiot.controller;

import com.smartquit.smartquitiot.dto.request.ChatbotPayload;
import com.smartquit.smartquitiot.dto.response.ChatbotResponse;
import com.smartquit.smartquitiot.dto.response.GlobalResponse;
import com.smartquit.smartquitiot.service.ChatbotService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/chatbot")
@RequiredArgsConstructor
@Slf4j
public class ChatbotController {

    private final ChatbotService chatbotService;
    private final SimpMessagingTemplate simpMessagingTemplate;

    @PostMapping
    public ResponseEntity<?> chatBot(@RequestBody ChatbotPayload chatbotPayload){
        ChatbotResponse aiResponse = chatbotService.personalizedChat(chatbotPayload);
        simpMessagingTemplate.convertAndSend("/topic/chatbot/" + chatbotPayload.getMemberId(), aiResponse);
        return ResponseEntity.ok(aiResponse);

    }

    @MessageMapping("/chatbot")
    public void chatWithAI(@Payload ChatbotPayload chatbotPayload){
        ChatbotResponse aiResponse = chatbotService.personalizedChat(chatbotPayload);
        simpMessagingTemplate.convertAndSend("/topic/chatbot/" + chatbotPayload.getMemberId(), aiResponse);
    }

    @GetMapping("/{conversationId}")
    public ResponseEntity<?> getChatbotMessagesByConversationId(@PathVariable Integer conversationId){
        return ResponseEntity.ok(chatbotService.getChatbotMessagesByConversationId(conversationId));
    }

    @PostMapping(value = "/voice", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public GlobalResponse<ChatbotResponse> chatVoice(
            @RequestPart("file") MultipartFile file,
            @RequestParam("memberId") String memberId) {

        ChatbotResponse response = chatbotService.chatWithVoice(file, memberId);
        return GlobalResponse.ok(response);
    }
}
