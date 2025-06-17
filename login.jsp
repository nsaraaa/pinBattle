<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Login - Image Selection Game</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="css/loginStyle.css" rel="stylesheet">
</head>
<body>
    <div class="login-container">
        <!-- Floating particles -->
        <div class="particle"></div>
        <div class="particle"></div>
        <div class="particle"></div>
        
        <div class="login-header">
            <h1 class="login-title">
                <i class="fas fa-images"></i>
                Welcome Back
            </h1>
            <p class="login-subtitle">Sign in to continue your image selection journey</p>
        </div>

        <% if (request.getAttribute("error") != null) { %>
            <div class="error-message">
                <i class="fas fa-exclamation-triangle"></i>
                ${error}
            </div>
        <% } %>

        <form action="login" method="post" id="loginForm">
            <div class="form-group">
                <label for="username" class="form-label">
                    <i class="fas fa-user"></i>
                    Username
                </label>
                <div style="position: relative;">
                    <i class="fas fa-user input-icon"></i>
                    <input 
                        type="text" 
                        id="username" 
                        name="username" 
                        class="form-input"
                        placeholder="Enter your username"
                        required
                        autocomplete="username"
                    >
                </div>
            </div>

            <div class="form-group">
                <label for="password" class="form-label">
                    <i class="fas fa-lock"></i>
                    Password
                </label>
                <div style="position: relative;">
                    <i class="fas fa-lock input-icon"></i>
                    <input 
                        type="password" 
                        id="password" 
                        name="password" 
                        class="form-input"
                        placeholder="Enter your password"
                        required
                        autocomplete="current-password"
                    >
                </div>
            </div>

            <button type="submit" class="login-button" id="loginBtn">
                <i class="fas fa-sign-in-alt"></i>
                Sign In
            </button>
        </form>

        <div class="register-link">
            Don't have an account? 
            <a href="register.jsp">
                <i class="fas fa-user-plus"></i>
                Create one here
            </a>
        </div>
    </div>

    <script>
        // Enhanced form interactions
        document.addEventListener('DOMContentLoaded', function() {
            const form = document.getElementById('loginForm');
            const loginBtn = document.getElementById('loginBtn');
            const inputs = document.querySelectorAll('.form-input');

            // Add floating label effect
            inputs.forEach(input => {
                input.addEventListener('focus', function() {
                    this.parentElement.classList.add('focused');
                });

                input.addEventListener('blur', function() {
                    if (!this.value) {
                        this.parentElement.classList.remove('focused');
                    }
                });

                // Check if input has value on page load
                if (input.value) {
                    input.parentElement.classList.add('focused');
                }
            });

            // Form submission with loading state
            form.addEventListener('submit', function(e) {
                loginBtn.classList.add('loading');
                loginBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Signing In...';
                
                // Prevent multiple submissions
                loginBtn.disabled = true;
            });

            // Add enter key support for smoother UX
            inputs.forEach(input => {
                input.addEventListener('keypress', function(e) {
                    if (e.key === 'Enter') {
                        const nextInput = input.parentElement.parentElement.nextElementSibling?.querySelector('.form-input');
                        if (nextInput) {
                            nextInput.focus();
                        } else {
                            form.requestSubmit();
                        }
                    }
                });
            });

            // Shake animation for invalid inputs
            inputs.forEach(input => {
                input.addEventListener('invalid', function() {
                    this.parentElement.style.animation = 'shake 0.5s ease-in-out';
                    setTimeout(() => {
                        this.parentElement.style.animation = '';
                    }, 500);
                });
            });
        });

        // Add some visual feedback for password visibility toggle (if needed in future)
        function togglePasswordVisibility() {
            const passwordInput = document.getElementById('password');
            const icon = passwordInput.parentElement.querySelector('.input-icon');
            
            if (passwordInput.type === 'password') {
                passwordInput.type = 'text';
                icon.className = 'fas fa-eye input-icon';
            } else {
                passwordInput.type = 'password';
                icon.className = 'fas fa-lock input-icon';
            }
        }
    </script>
</body>
</html>