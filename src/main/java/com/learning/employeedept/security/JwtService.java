package com.learning.employeedept.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Arrays;
import java.util.Date;
import java.util.function.Function;

@Service // Spring bean — handles all JWT create/parse/validate logic
public class JwtService {

    // Custom claim inside JWT to distinguish access vs refresh tokens
    private static final String TOKEN_TYPE_CLAIM = "type";
    private static final String ACCESS_TOKEN_TYPE = "access";
    private static final String REFRESH_TOKEN_TYPE = "refresh";

    private final SecretKey secretKey; // HMAC key used to sign tokens
    private final long expirationMs; // Access token lifetime (from application.yml)
    private final long refreshExpirationMs; // Refresh token lifetime (longer)

    public JwtService(@Value("${app.jwt.secret}") String secret,
                      @Value("${app.jwt.expiration-ms}") long expirationMs,
                      @Value("${app.jwt.refresh-expiration-ms}") long refreshExpirationMs) {
        byte[] keyBytes = secret.getBytes(StandardCharsets.UTF_8);
        // HMAC-SHA256 needs at least 256 bits (32 bytes) for security
        if (keyBytes.length < 32) {
            throw new IllegalArgumentException("JWT secret must be at least 32 characters");
        }
        this.secretKey = Keys.hmacShaKeyFor(Arrays.copyOf(keyBytes, 32));
        this.expirationMs = expirationMs;
        this.refreshExpirationMs = refreshExpirationMs;
    }

    /** Reads the username (subject) stored inside the JWT. */
    public String extractUsername(String token) {
        return extractClaim(token, Claims::getSubject);
    }

    /** Creates a short-lived access token used on every API call. */
    public String generateToken(UserDetails userDetails) {
        return buildToken(userDetails.getUsername(), expirationMs, ACCESS_TOKEN_TYPE);
    }

    /** Creates a long-lived refresh token used only to get new access tokens. */
    public String generateRefreshToken(UserDetails userDetails) {
        return buildToken(userDetails.getUsername(), refreshExpirationMs, REFRESH_TOKEN_TYPE);
    }

    /** True if access token matches user and is not expired. */
    public boolean isTokenValid(String token, UserDetails userDetails) {
        return isAccessToken(token)
                && extractUsername(token).equals(userDetails.getUsername())
                && !isTokenExpired(token);
    }

    /** True if refresh token matches user and is not expired. */
    public boolean isRefreshTokenValid(String token, UserDetails userDetails) {
        return isRefreshToken(token)
                && extractUsername(token).equals(userDetails.getUsername())
                && !isTokenExpired(token);
    }

    /** Checks the "type" claim equals "access". */
    public boolean isAccessToken(String token) {
        return ACCESS_TOKEN_TYPE.equals(extractTokenType(token));
    }

    /** Checks the "type" claim equals "refresh". */
    public boolean isRefreshToken(String token) {
        return REFRESH_TOKEN_TYPE.equals(extractTokenType(token));
    }

    /** Builds and signs a JWT with username, expiry, and token type. */
    private String buildToken(String username, long ttlMs, String tokenType) {
        return Jwts.builder()
                .subject(username) // "sub" claim — who this token belongs to
                .claim(TOKEN_TYPE_CLAIM, tokenType) // access or refresh
                .issuedAt(new Date()) // when token was created
                .expiration(new Date(System.currentTimeMillis() + ttlMs)) // when it expires
                .signWith(secretKey) // HMAC signature — tampering breaks validation
                .compact(); // Final string sent to the client
    }

    private String extractTokenType(String token) {
        return extractClaim(token, claims -> claims.get(TOKEN_TYPE_CLAIM, String.class));
    }

    /** Expired if expiration date is before now. */
    private boolean isTokenExpired(String token) {
        return extractClaim(token, Claims::getExpiration).before(new Date());
    }

    /** Parses JWT, verifies signature, returns any claim we ask for. */
    private <T> T extractClaim(String token, Function<Claims, T> resolver) {
        Claims claims = Jwts.parser()
                .verifyWith(secretKey) // Reject tokens signed with wrong key
                .build()
                .parseSignedClaims(token)
                .getPayload();
        return resolver.apply(claims);
    }
}
