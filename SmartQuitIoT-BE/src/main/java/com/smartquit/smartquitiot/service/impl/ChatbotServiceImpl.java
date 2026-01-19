package com.smartquit.smartquitiot.service.impl;

import com.smartquit.smartquitiot.client.AiServiceClient;
import com.smartquit.smartquitiot.dto.request.ChatbotPayload;
import com.smartquit.smartquitiot.dto.request.TextToVoiceRequest;
import com.smartquit.smartquitiot.dto.response.ChatbotResponse;
import com.smartquit.smartquitiot.dto.response.MemberDTO;
import com.smartquit.smartquitiot.dto.response.VoiceToTextResponse;
import com.smartquit.smartquitiot.mapper.ChatbotResponseMapper;
import com.smartquit.smartquitiot.service.ChatbotService;
import com.smartquit.smartquitiot.service.MemberService;
import com.smartquit.smartquitiot.toolcalling.ChatbotTools;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.client.advisor.MessageChatMemoryAdvisor;
import org.springframework.ai.chat.memory.ChatMemory;
import org.springframework.ai.chat.memory.MessageWindowChatMemory;
import org.springframework.ai.chat.memory.repository.jdbc.JdbcChatMemoryRepository;
import org.springframework.ai.chat.messages.AssistantMessage;
import org.springframework.ai.chat.messages.Message;
import org.springframework.ai.chat.messages.SystemMessage;
import org.springframework.ai.chat.messages.UserMessage;
import org.springframework.ai.chat.prompt.Prompt;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.util.Base64;
import java.util.List;


import static com.smartquit.smartquitiot.toolcalling.ChatbotTools.CHATBOT_PROMPT;

@Slf4j
@Service
public class ChatbotServiceImpl implements ChatbotService {

    private final JdbcChatMemoryRepository chatMemoryRepository;
    private final MemberService memberService;
    private final ChatClient chatClient;
    private final ChatbotTools chatbotTools;
    private final ChatbotResponseMapper chatbotResponseMapper;
    private final AiServiceClient aiServiceClient;

    public ChatbotServiceImpl(ChatClient.Builder chatClientBuilder,
                              JdbcChatMemoryRepository chatMemoryRepository,
                              MemberService memberService,
                              ChatbotTools chatbotTools,
                              ChatbotResponseMapper chatbotResponseMapper, AiServiceClient aiServiceClient) {
        this.chatbotResponseMapper = chatbotResponseMapper;
        this.chatMemoryRepository = chatMemoryRepository;
        this.memberService = memberService;
        this.aiServiceClient = aiServiceClient;
        ChatMemory chatMemory = MessageWindowChatMemory
                .builder()
                .chatMemoryRepository(chatMemoryRepository)
                .maxMessages(30)
                .build();

        this.chatClient = chatClientBuilder
                .defaultAdvisors(MessageChatMemoryAdvisor.builder(chatMemory).build())
                .build();
        this.chatbotTools = chatbotTools;

    }

    @Override
    public ChatbotResponse chatWithVoice(MultipartFile voiceFile, String memberId) {
        VoiceToTextResponse sttResponse = aiServiceClient.voiceToText(voiceFile);
        if (sttResponse == null || sttResponse.getText() == null) {
            throw new RuntimeException("Failed to convert voice to text");
        }

        ChatbotPayload payload = new ChatbotPayload();
        payload.setMemberId(memberId);
        payload.setMessage(sttResponse.getText());

        return personalizedChat(payload);
    }

    @Override
    public List<Message> getChatbotMessagesByConversationId(Integer conversationId) {
        String strConversationId = String.valueOf(conversationId);
        return chatMemoryRepository.findByConversationId(strConversationId);
    }


    @Override
    public ChatbotResponse personalizedChat(ChatbotPayload payload) {
        MemberDTO member = memberService.getMemberById(Integer.parseInt(payload.getMemberId()));

        String userContext = String.format("""
                ### USER CONTEXT:
                - Member ID: %d
                - Name: %s
                - Age: %d
                - Gender: %s
                """,
                member.getId(),
                member.getFirstName() + " " + member.getLastName(),
                member.getAge(),
                member.getGender());

        SystemMessage systemMessage = new SystemMessage(CHATBOT_PROMPT + "\n" + userContext);
        UserMessage userMessage = new UserMessage(payload.getMessage());
        Prompt prompt = new Prompt(systemMessage, userMessage);

        AssistantMessage message = chatClient.prompt(prompt)
                .tools(chatbotTools)
                .advisors(advisorSpec -> advisorSpec.param(ChatMemory.CONVERSATION_ID, member.getId()))
                .call().chatClientResponse().chatResponse().getResult().getOutput();

        ChatbotResponse response = chatbotResponseMapper.toChatbotResponse(message);
        if (response.getText() != null && !response.getText().isEmpty()) {
            try {
                TextToVoiceRequest ttsRequest = TextToVoiceRequest.builder()
                        .text(response.getText())
                        .build();

                byte[] audioBytes = aiServiceClient.textToVoice(ttsRequest);

                if (audioBytes != null && audioBytes.length > 0) {
                    String base64Audio = Base64.getEncoder().encodeToString(audioBytes);
                    response.setAudioBase64(base64Audio);
                }
            } catch (Exception e) {
                log.error("Failed to generate voice for chatbot response", e);

            }
        }
        return response;

    }
}
