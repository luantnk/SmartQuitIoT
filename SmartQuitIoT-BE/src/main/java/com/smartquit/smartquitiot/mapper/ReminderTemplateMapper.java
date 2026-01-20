package com.smartquit.smartquitiot.mapper;

import com.smartquit.smartquitiot.dto.response.ReminderTemplateDTO;
import com.smartquit.smartquitiot.entity.ReminderTemplate;
import org.springframework.stereotype.Component;

@Component
public class ReminderTemplateMapper {
  public ReminderTemplateDTO toReminderTemplateDTO(ReminderTemplate reminderTemplate) {
    if (reminderTemplate == null) {
      return null;
    }
    ReminderTemplateDTO reminderTemplateDTO = new ReminderTemplateDTO();
    reminderTemplateDTO.setId(reminderTemplate.getId());
    reminderTemplateDTO.setPhaseEnum(reminderTemplate.getPhaseEnum());
    reminderTemplateDTO.setReminderType(reminderTemplate.getReminderType());
    reminderTemplateDTO.setContent(reminderTemplate.getContent());
    reminderTemplateDTO.setTriggerCode(reminderTemplate.getTriggerCode());
    reminderTemplateDTO.setCreatedAt(reminderTemplate.getCreatedAt());
    reminderTemplateDTO.setUpdatedAt(reminderTemplate.getUpdatedAt());
    return reminderTemplateDTO;
  }
}
