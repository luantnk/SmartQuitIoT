package com.smartquit.smartquitiot.service;

import com.smartquit.smartquitiot.dto.request.ChatbotPayload;
import com.smartquit.smartquitiot.dto.response.ChatbotResponse;
import org.springframework.ai.chat.messages.Message;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

public interface ChatbotService {
    List<Message> getChatbotMessagesByConversationId(Integer conversationId);


    ChatbotResponse chatWithVoice(MultipartFile voiceFile, String memberId);

    ChatbotResponse personalizedChat(ChatbotPayload payload);

}
