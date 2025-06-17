<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Register - Image Selection Game</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="css/registerStyle.css" rel="stylesheet">

</head>
<body>
    <div class="login-container">
        <!-- Floating particles -->
        <div class="particle"></div>
        <div class="particle"></div>
        <div class="particle"></div>
        
        <div class="login-header">
            <h1 class="login-title">
                <i class="fas fa-user-plus"></i>
                Create Account
            </h1>
            <p class="login-subtitle">Join our image selection community</p>
        </div>

        <% if (request.getAttribute("error") != null) { %>
            <div class="error-message">
                <i class="fas fa-exclamation-triangle"></i>
                ${error}
            </div>
        <% } %>

        <form action="register" method="post" id="registerForm">
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
                        placeholder="Choose a username"
                        required
                        autocomplete="username"
                    >
                </div>
            </div>

            <div class="form-group">
                <label for="email" class="form-label">
                    <i class="fas fa-envelope"></i>
                    Email
                </label>
                <div style="position: relative;">
                    <i class="fas fa-envelope input-icon"></i>
                    <input 
                        type="email" 
                        id="email" 
                        name="email" 
                        class="form-input"
                        placeholder="Enter your email"
                        required
                        autocomplete="email"
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
                        placeholder="Create a password"
                        required
                        autocomplete="new-password"
                    >
                </div>
            </div>

            <button type="submit" class="login-button" id="registerBtn">
                <i class="fas fa-user-plus"></i>
                Register
            </button>
        </form>

        <div class="register-link">
            Already have an account? 
            <a href="login.jsp">
                <i class="fas fa-sign-in-alt"></i>
                Sign in here
            </a>
        </div>
    </div>

    <script>
        // Enhanced form interactions
        document.addEventListener('DOMContentLoaded', function() {
            const form = document.getElementById('registerForm');
            const registerBtn = document.getElementById('registerBtn');
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
                registerBtn.classList.add('loading');
                registerBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Registering...';
                
                // Prevent multiple submissions
                registerBtn.disabled = true;
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