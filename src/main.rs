use headless_chrome::Browser;
use std::{env, fs};
use headless_chrome::protocol::cdp::Page::CaptureScreenshotFormatOption;

fn main() {
    let browser = Browser::default()
        .expect("Failed to initialize browser");

    let tab = browser.new_tab()
        .expect("Failed to open tab");

    tab.navigate_to(&*env::var("WSA_URL").unwrap())
        .expect("Failed to navigate to URL");

    let png = tab.capture_screenshot(
        CaptureScreenshotFormatOption::Png,
        None,
        None,
        true
    ).expect("Failed to capture png");
    fs::write("screenshot.png", png)
        .expect("Failed to write to screenshot");
}
