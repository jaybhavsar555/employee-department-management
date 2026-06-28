package com.learning.employeedept.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@Builder
@AllArgsConstructor
public class ActivityItemResponse {

    private final ActivityType type;
    private final String message;
    private final Long entityId;
    private final LocalDateTime timestamp;
}
