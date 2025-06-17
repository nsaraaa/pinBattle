<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Game Session</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="css/styles.css" rel="stylesheet">
    <style>
      
    </style>
</head>
<body>
    <div class="game-container fade-in">
        <div class="header slide-in">
            <div class="game-title">
                <i class="fas fa-images"></i>
                Image Selection Game
            </div>
            <div class="timer" id="timer">
                <i class="fas fa-clock"></i>
                02:00
            </div>
            <div class="players-list">
                <div class="player current-player">
                    <i class="fas fa-user"></i>
                    You
                </div>
                <div class="player">
                    <i class="fas fa-user-friends"></i>
                    Player2
                </div>
                <div class="player">
                    <i class="fas fa-user-friends"></i>
                    Player3
                </div>
                <div class="player">
                    <i class="fas fa-user-friends"></i>
                    Player4
                </div>
            </div>
        </div>
        
        <div class="content-area">
            <div class="theme-info slide-in">
                <div class="theme-title">
                    <i class="fas fa-palette"></i>
                    Theme: <span id="game-theme">${param.theme}</span>
                </div>
                <div class="theme-description">
                    Select images that best represent the theme. 
                    You can select up to <span class="selected-count">5</span> images.
                </div>
                <div id="debug-info" class="debug-info">
                    <i class="fas fa-bug"></i> Debug: Initializing...
                </div>
            </div>
            
            <div class="image-grid-container fade-in">
                <div class="search-box">
                    <input type="text" class="search-input" id="search-input" placeholder="Search for images...">
                    <button class="btn btn-primary" id="search-btn">
                        <i class="fas fa-search"></i>
                        Search
                    </button>
                </div>
                
                <div id="loading" class="loading" style="display: none;">
                    <div class="spinner"></div>
                </div>
                
                <div class="image-grid" id="image-grid">
                    <!-- Images will be loaded here via JavaScript -->
                </div>
            </div>
        </div>
        
        <div class="action-bar fade-in">
            <div class="selection-info">
                <i class="fas fa-check-circle"></i>
                Selected: <span id="selected-count">0</span>/5
            </div>
            <button class="btn btn-success" id="submit-btn" disabled>
                <i class="fas fa-paper-plane"></i>
                Submit Selection
            </button>
        </div>
    </div>

<script>
// ======================
// Unsplash API Logic
// ======================

async function fetchUnsplashImages(query = '') {
    // Show loading spinner if present
    const loading = document.getElementById('loading');
    if (loading) loading.style.display = 'flex';

    let url = 'UnsplashServlet';
    if (query && query.trim().length > 0) {
        url += '?query=' + encodeURIComponent(query.trim());
    }
    try {
        const response = await fetch(url, {
            method: 'GET',
            headers: { 'Accept': 'application/json' }
        });
        const data = await response.json();
        return data.images || [];
    } catch (err) {
        console.error('Failed to fetch images:', err);
        return [];
    } finally {
        if (loading) loading.style.display = 'none';
    }
}

function renderUnsplashImages(images) {
    const imageGrid = document.getElementById('image-grid');
    imageGrid.innerHTML = '';
    if (!images || images.length === 0) {
        imageGrid.innerHTML = '<div class="image-error"><i class="fas fa-exclamation-triangle"></i> No images found.</div>';
        return;
    }
    images.forEach((img, idx) => {
        const card = document.createElement('div');
        card.className = 'image-card';
        card.dataset.index = idx;

        // Actual Unsplash image
        const imageTag = document.createElement('img');
        imageTag.src = img.url;
        imageTag.alt = img.description || `Image ${idx + 1}`;
        imageTag.onerror = function () {
            card.innerHTML = '<div class="image-error"><i class="fas fa-exclamation-triangle"></i> Could not load image</div>';
        };

        // Info overlay
        const infoDiv = document.createElement('div');
        infoDiv.className = 'image-info';
        infoDiv.innerHTML = `<strong>${img.description || ''}</strong><br>by ${img.user}`;

        card.appendChild(imageTag);
        card.appendChild(infoDiv);

        // Selection logic (if needed)
        card.addEventListener('click', () => toggleImageSelection(card, idx));

        imageGrid.appendChild(card);
    });
}

// ======================
// Game Logic
// ======================

document.addEventListener('DOMContentLoaded', function () {
    // Debug function to track execution
    function updateDebug(message) {
        const debugInfo = document.getElementById('debug-info');
        if (debugInfo) {
            debugInfo.innerHTML = `<i class="fas fa-bug"></i> Debug: ${message}`;
            console.log('Debug:', message);
        }
    }

    // Get URL parameters
    const urlParams = new URLSearchParams(window.location.search);
    const sessionId = urlParams.get('sessionId');
    const theme = urlParams.get('theme');

    if (!sessionId) {
        alert('No session ID provided. Please join a game session first.');
        window.location.href = '/';
        return;
    }

    // Fixed game state with all required properties
    const gameState = {
        sessionId: sessionId,
        theme: theme || 'abstract',
        maxPlayers: parseInt(urlParams.get('maxPlayers')) || 4,
        currentPlayers: parseInt(urlParams.get('currentPlayers')) || 1,
        selectedImages: [],
        maxSelections: 5,
        timeLeft: 120, // 2 minutes in seconds
        timerInterval: null
    };

    console.log('Game state initialized:', gameState);

    // DOM elements
    const imageGrid = document.getElementById('image-grid');
    const searchInput = document.getElementById('search-input');
    const searchBtn = document.getElementById('search-btn');
    const submitBtn = document.getElementById('submit-btn');
    const selectedCount = document.getElementById('selected-count');
    const timerElement = document.getElementById('timer');
    const loadingElement = document.getElementById('loading');
    const gameThemeElement = document.getElementById('game-theme');

    // Update the theme display
    if (gameThemeElement) {
        gameThemeElement.textContent = gameState.theme || 'abstract';
    }

    // Setup search
    if (searchBtn) {
        searchBtn.addEventListener('click', handleSearch);
    }

    if (searchInput) {
        searchInput.addEventListener('keypress', (e) => {
            if (e.key === 'Enter') handleSearch();
        });
    }

    if (submitBtn) {
        submitBtn.addEventListener('click', submitSelection);
    }

    // Timer logic
    startTimer();

    // Initial Unsplash load
    updateDebug('Loading images from Unsplash...');
    fetchUnsplashImages(gameState.theme).then(renderUnsplashImages);

    // Timer functionality
    function startTimer() {
        updateDebug('Timer started');
        if (gameState.timerInterval) {
            clearInterval(gameState.timerInterval);
        }
        gameState.timerInterval = setInterval(() => {
            if (gameState.timeLeft <= 0) {
                clearInterval(gameState.timerInterval);
                if (timerElement) {
                    timerElement.innerHTML = "<i class='fas fa-exclamation-triangle'></i> Time's up!";
                    timerElement.classList.add('warning');
                }
                if (gameState.selectedImages.length > 0) {
                    submitSelection();
                }
                return;
            }
            gameState.timeLeft--;
            const minutes = Math.floor(gameState.timeLeft / 60);
            const seconds = gameState.timeLeft % 60;

            if (timerElement) {
                timerElement.innerHTML = `<i class="fas fa-clock"></i> ${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
                if (gameState.timeLeft <= 30) {
                    timerElement.classList.add('warning');
                }
            }
        }, 1000);
    }

    function handleSearch() {
        if (!searchInput) return;
        const query = searchInput.value.trim() || gameState.theme;
        updateDebug(`Searching Unsplash for: ${query}`);
        fetchUnsplashImages(query).then(renderUnsplashImages);
        // Clear selection state after new search
        gameState.selectedImages = [];
        if (selectedCount) selectedCount.textContent = '0';
        if (submitBtn) submitBtn.disabled = true;
    }

    // Selection logic
    window.toggleImageSelection = function(card, imageIndex) {
        if (!card) return;
        const isSelected = card.classList.contains('selected');
        if (isSelected) {
            // Remove from array
            const index = gameState.selectedImages.indexOf(imageIndex);
            if (index > -1) {
                gameState.selectedImages.splice(index, 1);
            }
            card.classList.remove('selected');
            updateDebug(`Deselected image ${imageIndex + 1}`);
        } else {
            if (gameState.selectedImages.length < gameState.maxSelections) {
                gameState.selectedImages.push(imageIndex);
                card.classList.add('selected');
                updateDebug(`Selected image ${imageIndex + 1}`);
            } else {
                updateDebug(`Cannot select more than ${gameState.maxSelections} images`);
            }
        }
        if (selectedCount) {
            selectedCount.textContent = gameState.selectedImages.length;
        }
        if (submitBtn) {
            submitBtn.disabled = gameState.selectedImages.length === 0;
        }
    }

    function submitSelection() {
        if (gameState.selectedImages.length === 0) return;
        
        console.log('Starting submission process...');
        
        // Get all image cards currently in the DOM
        const allCards = Array.from(document.querySelectorAll('.image-card'));
        
        // Collect selected images data
        const selectedImageData = gameState.selectedImages.map(index => {
            const card = allCards[index];
            const img = card.querySelector('img');
            const info = card.querySelector('.image-info');
            return {
                index: index,
                url: img.src,
                description: info ? info.textContent.trim() : ''
            };
        });
        
        console.log('Selected images data:', selectedImageData);
        
        // Prepare data for storage
        const data = {
            sessionId: gameState.sessionId,
            theme: gameState.theme,
            username: 'bscs23162',
            selectedImages: selectedImageData,
            timestamp: new Date().toISOString()
        };
        
        // Store in session storage
        try {
            // Get existing submissions or initialize new array
            let submissions = JSON.parse(sessionStorage.getItem('imageSubmissions') || '[]');
            
            // Add new submission
            submissions.push(data);
            
            // Save back to session storage
            sessionStorage.setItem('imageSubmissions', JSON.stringify(submissions));
            
            console.log('Saved submissions:', submissions);
            
            // Redirect to vote page
            window.location.href = 'vote.html?sessionId=' + gameState.sessionId;
        } catch (error) {
            console.error('Error saving to session storage:', error);
            alert('Error saving your selections. Please try again.');
        }
    }

    // Cleanup timer when leaving page
    window.addEventListener('beforeunload', () => {
        if (gameState.timerInterval) {
            clearInterval(gameState.timerInterval);
        }
    });
});
</script>
</body>
</html>