package com.smartquit.smartquitiot.dto.request;

import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class CommentCreateRequest {
  private String content;
  private Integer parentId;
  private List<CommentMediaRequest> media;

  @Getter
  @Setter
  @NoArgsConstructor
  @AllArgsConstructor
  public static class CommentMediaRequest {
    private String mediaUrl;
    private String mediaType;
  }
}
