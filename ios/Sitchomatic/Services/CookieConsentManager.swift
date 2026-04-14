// CookieConsentManager.swift
// rork-Sitchomatic-iOS
//
// Specialized service for managing cookie consent across all WebViews.
// Provides atDocumentStart script injection to prevent flicker and
// MutationObserver to catch late-injected banners.

import Foundation
@preconcurrency import WebKit

@MainActor
final class CookieConsentManager {
    static let shared = CookieConsentManager()

    private let consentKey = "cookieConsentGiven"
    private var webViews = NSHashTable<WKWebView>.weakObjects()

    var hasConsent: Bool {
        get { UserDefaults.standard.bool(forKey: consentKey) }
        set { UserDefaults.standard.set(newValue, forKey: consentKey) }
    }

    private init() {
        // Migration: If we had a legacy flag, we could migrate it here.
    }

    /// Registers a WebView for manual consent application if granted later.
    func register(_ webView: WKWebView) {
        webViews.add(webView)
    }

    /// Grants consent globally and applies hiding JS to all active WebViews.
    func grantConsent() async {
        hasConsent = true
        let js = generateConsentJS(includeCookie: true)
        
        await withTaskGroup(of: Void.self) { group in
            for webView in webViews.allObjects {
                group.addTask {
                    _ = try? await webView.evaluateJavaScript(js)
                }
            }
        }
    }

    /// Returns a WKUserScript that hides cookie banners at document start.
    func consentHidingUserScript() -> WKUserScript {
        let source = hasConsent ? generateConsentJS(includeCookie: true) : ""
        return WKUserScript(
            source: source,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: false
        )
    }

    private func generateConsentJS(includeCookie: Bool) -> String {
        let frameworkSelectors = [
            "#onetrust-accept-btn-handler",
            ".onetrust-close-btn-handler",
            "#CybotCookiebotDialogBodyLevelButtonLevelOptinAllowAll",
            "#CybotCookiebotDialogBodyButtonAccept",
            ".cc-accept",
            ".cc-btn.cc-allow",
            ".cc-dismiss",
            "#didomi-notice-agree-button",
            "#truste-consent-button",
            "#consent-accept",
            "#accept-cookies",
            ".js-accept-cookies",
            ".js-cookie-accept",
            "[data-action=\"accept\"]",
            "[data-cookieconsent=\"accept\"]",
            ".cookie-consent-accept",
            ".cookie-accept-all",
            ".gdpr-accept",
            ".privacy-accept",
            "#gdpr-cookie-accept",
            "#cookie-accept",
            ".fc-cta-consent",
            ".fc-button.fc-cta-consent"
        ]

        let overlaySelectors = [
            "[class*=\"cookie\"]",
            "[class*=\"consent\"]",
            "[class*=\"gdpr\"]",
            "[class*=\"privacy\"]",
            "[id*=\"cookie\"]",
            "[id*=\"consent\"]",
            "[id*=\"gdpr\"]",
            "[id*=\"privacy\"]",
            "[aria-label*=\"cookie\" i]",
            "[aria-label*=\"consent\" i]",
            "[role=\"dialog\"]",
            "[aria-modal=\"true\"]"
        ]

        let selectorsJS = (frameworkSelectors + overlaySelectors)
            .map { "'\($0)'" }
            .joined(separator: ", ")

        return """
        (function() {
            if (window.__cookieConsentApplied) return;
            window.__cookieConsentApplied = true;

            const selectors = [\(selectorsJS)];

            function isVisible(el) {
                if (!el) return false;
                const rect = el.getBoundingClientRect();
                if (rect.width <= 0 || rect.height <= 0) return false;
                const style = window.getComputedStyle(el);
                return style.display !== 'none' && style.visibility !== 'hidden' && style.opacity !== '0';
            }

            function isConsentOverlay(el, selector) {
                if (!isVisible(el)) return false;
                
                // If it's a known framework selector, we trust it's a cookie banner
                if (!selector.includes('[class*') && !selector.includes('[id*') && 
                    !selector.includes('[role=') && !selector.includes('[aria-')) {
                    return true;
                }

                const style = window.getComputedStyle(el);
                const text = (el.textContent || '').toLowerCase();
                const positioned = style.position === 'fixed' || style.position === 'sticky' || parseInt(style.zIndex || '0', 10) >= 100;
                const modal = el.getAttribute('role') === 'dialog' || el.getAttribute('aria-modal') === 'true';
                
                const mentionsConsent = text.includes('cookie') || text.includes('consent') || 
                                       text.includes('gdpr') || text.includes('privacy') || 
                                       text.includes('tracking') || text.includes('preferences');
                
                // Tighten: must be positioned/modal AND mention consent-related keywords
                return (positioned || modal) && mentionsConsent;
            }

            function hideBanners() {
                selectors.forEach(s => {
                    try {
                        const elements = document.querySelectorAll(s);
                        elements.forEach(el => {
                            if (isConsentOverlay(el, s)) {
                                el.style.display = 'none';
                                el.style.pointerEvents = 'none';
                                el.style.opacity = '0';
                            }
                        });
                    } catch (e) {}
                });
            }

            // Initial pass
            if (document.readyState === 'loading') {
                document.addEventListener('DOMContentLoaded', hideBanners);
            } else {
                hideBanners();
            }

            // Feature 10: Consent-O-Matic cavi-au Heuristic Auto-Reject Port
            // Actively seeks and clicks 'Reject All' / 'Deny' buttons before hiding them
            function executeConsentOMaticReject() {
                try {
                    const rejectTerms = ['reject all', 'deny', 'decline', 'refuse', 'essential only', 'disallow', 'continue without accepting'];
                    const buttons = Array.from(document.querySelectorAll('button, a, [role="button"]'));
                    for (let i = 0; i < buttons.length; i++) {
                        let btn = buttons[i];
                        if (btn.offsetWidth === 0 || btn.offsetHeight === 0) continue;
                        let text = (btn.textContent || '').trim().toLowerCase();
                        for (let term of rejectTerms) {
                            if (text === term || (text.includes(term) && text.length < 30)) {
                                btn.click();
                                btn.dispatchEvent(new Event('click', { bubbles: true }));
                                return true;
                            }
                        }
                    }
                } catch (e) {}
                return false;
            }

            // Execute Consent-O-Matic clicker asynchronously to allow DOM parsing
            setTimeout(() => { if (!executeConsentOMaticReject()) hideBanners(); }, 800);

            // Mutation observer for late-injected banners
            const observer = new MutationObserver((mutations) => {
                executeConsentOMaticReject();
                hideBanners();
            });

            observer.observe(document.documentElement, {
                childList: true,
                subtree: true
            });

            // Set storage and cookies if requested
            if (\(includeCookie)) {
                try {
                    const domain = window.location.hostname;
                    const expires = new Date(Date.now() + 31536000000).toUTCString(); // 1 year
                    const cookieBase = "; domain=" + domain + "; path=/; expires=" + expires + "; SameSite=Lax";
                    
                    document.cookie = "cookie-consent=true" + cookieBase;
                    document.cookie = "gdpr-consent=true" + cookieBase;
                    document.cookie = "consent-status=accepted" + cookieBase;
                    
                    localStorage.setItem('cookie-consent', 'true');
                    localStorage.setItem('gdpr-consent', 'true');
                    localStorage.setItem('cookieConsentGiven', 'true');
                } catch (e) {}
            }
        })();
        """
    }
}
