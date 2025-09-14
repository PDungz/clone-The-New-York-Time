// Home WebView Theme - Extracted from original _applyThemeStyles() method
(function() {
  'use strict';
  
  console.log('Home WebView Theme: Applying theme...');
  
  try {
    // Original theme application logic
    const root = document.documentElement;
    
    // CSS custom properties will be set from Dart
    // root.style.setProperty('--theme-background', themeBackground);
    // root.style.setProperty('--theme-text', themeTextPrimary);
    // root.style.setProperty('--theme-primary', themePrimary);
    // root.style.setProperty('--theme-secondary', themeSecondary);
    
    // Keep original element removal logic
    const unwantedElements = document.querySelectorAll('.ad, .advertisement, .banner-ad, .popup, .modal-overlay');
    unwantedElements.forEach(el => el.remove());
    
    // Add reading mode class for new features
    document.body.classList.add('reading-mode');
    
    // Add smooth scroll behavior
    document.documentElement.style.scrollBehavior = 'smooth';
    
    console.log('Theme applied successfully');
    return 'Theme applied successfully';
    
  } catch (e) {
    console.error('Theme application failed:', e);
    return 'Theme application failed: ' + e.message;
  }
})();