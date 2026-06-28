package com.learning.employeedept.service;

import com.learning.employeedept.dto.request.LoginRequest;
import com.learning.employeedept.dto.request.RefreshTokenRequest;
import com.learning.employeedept.dto.request.RegisterRequest;
import com.learning.employeedept.dto.response.AuthResponse;

public interface AuthService {

    AuthResponse register(RegisterRequest request);

    AuthResponse login(LoginRequest request);

    AuthResponse refresh(RefreshTokenRequest request);
}
