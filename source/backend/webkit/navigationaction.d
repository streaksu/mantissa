module backend.webkit.navigationaction;

import backend.webkit.urirequest: WebkitURIRequest, URIRequest;

alias WebkitNavigationAction = void*;

/// Denotes various navigation types.
enum NavigationType {
    LinkClicked,     /// Triggered by clicking a link.
    FormSubmitted,   /// Triggered by submitting a form.
    BackFormward,    /// Triggered by navigating back or forward.
    Reload,          /// Triggered by reload.
    FormResubmitted, /// Triggered by resubmitting a form.
    Other,           /// Triggered by other actions.
}

private extern (C) {
    WebkitURIRequest webkit_navigation_action_get_request(WebkitNavigationAction);
    NavigationType webkit_navigation_action_get_navigation_type(WebkitNavigationAction);
    uint webkit_navigation_action_get_mouse_button(WebkitNavigationAction);
    bool webkit_navigation_action_is_user_gesture(WebkitNavigationAction);
    bool webkit_navigation_action_is_redirect(WebkitNavigationAction);
    uint webkit_navigation_action_get_modifiers(WebkitNavigationAction);
}

/**
 * Represents a browser navigation action.
 */
final class NavigationAction {
    /// The inner webkit struct pointer.
    WebkitNavigationAction webkitNavigationAction;

    /**
     * Returns the URIRequest associated with the action.
     */
    @property URIRequest request() {
        return new URIRequest(webkit_navigation_action_get_request(webkitNavigationAction));
    }

    /**
     * Returns the type of navigation that triggered the action.
     */
    @property NavigationType navigationType() {
        return webkit_navigation_action_get_navigation_type(webkitNavigationAction);
    }

    /**
     * Number of the mouse button that triggered the navigation, or 0 if
     * the navigation was not started by a mouse event.
     */
    @property uint mouseButton() {
        return webkit_navigation_action_get_mouse_button(webkitNavigationAction);
    }

    /**
     * Return whether the navigation was triggered by a user gesture
     * like a mouse click.
     */
    @property bool isUserGesture() {
        return webkit_navigation_action_is_user_gesture(webkitNavigationAction);
    }

    /**
     * Returns whether the navigation was redirected.
     */
    @property bool isRedirect() {
        return webkit_navigation_action_is_redirect(webkitNavigationAction);
    }

    /**
     * Return a bitmask of GdkModifierType values describing the modifier keys
     * that were in effect when the navigation was requested
     */
    @property uint modifiers() {
        return webkit_navigation_action_get_modifiers(webkitNavigationAction);
    }

    /**
     * Creates a new object using an inner webkit pointer.
     */
    this(WebkitNavigationAction manager, bool ow = false) {
        webkitNavigationAction = manager;
    }
}
