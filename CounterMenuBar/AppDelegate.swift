import Cocoa
import ServiceManagement
import Carbon
import UserNotifications

@main
class AppDelegate: NSObject, NSApplicationDelegate, NSTextFieldDelegate {
    
    private var statusItem: NSStatusItem!
    private var counter: Int = 0 {
        didSet {
            updateStatusItemTitle()
            UserDefaults.standard.set(counter, forKey: "CounterValue")
        }
    }
    
    private var hotKeyManager: HotKeyManager!
    private var emailTemplate: String {
        get {
            UserDefaults.standard.string(forKey: "EmailTemplate") ?? "email+{count}@example.com"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "EmailTemplate")
        }
    }
    private var configWindow: NSWindow?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        loadCounterValue()
        setupMenuBar()
        setupHotKeys()
        requestNotificationPermissions()
    }
    
    private func loadCounterValue() {
        counter = UserDefaults.standard.integer(forKey: "CounterValue")
    }
    
    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        updateStatusItemTitle()
        
        let menu = NSMenu()
        
        let incrementItem = NSMenuItem(title: "Increment (⌘⇧I)", action: #selector(incrementCounter), keyEquivalent: "")
        incrementItem.target = self
        menu.addItem(incrementItem)
        
        let decrementItem = NSMenuItem(title: "Decrement", action: #selector(decrementCounter), keyEquivalent: "")
        decrementItem.target = self
        menu.addItem(decrementItem)
        
        let copyEmailItem = NSMenuItem(title: "Copy Email (⌘⇧E)", action: #selector(copyEmail), keyEquivalent: "")
        copyEmailItem.target = self
        menu.addItem(copyEmailItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let configureEmailItem = NSMenuItem(title: "Configure Email Template...", action: #selector(showEmailConfiguration), keyEquivalent: "")
        configureEmailItem.target = self
        menu.addItem(configureEmailItem)
        
        let resetItem = NSMenuItem(title: "Reset Counter", action: #selector(resetCounter), keyEquivalent: "")
        resetItem.target = self
        menu.addItem(resetItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let launchAtLoginItem = NSMenuItem(title: "Launch at Login", action: #selector(toggleLaunchAtLogin), keyEquivalent: "")
        launchAtLoginItem.target = self
        if #available(macOS 13.0, *) {
            launchAtLoginItem.state = SMAppService.mainApp.status == .enabled ? .on : .off
        }
        menu.addItem(launchAtLoginItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let quitItem = NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        menu.addItem(quitItem)
        
        statusItem.menu = menu
    }
    
    private func setupHotKeys() {
        hotKeyManager = HotKeyManager()
        
        hotKeyManager.registerHotKey(keyCode: 0x22, modifiers: [.command, .shift]) { [weak self] in
            self?.incrementCounter()
        }
        
        hotKeyManager.registerHotKey(keyCode: 0x0E, modifiers: [.command, .shift]) { [weak self] in
            self?.copyEmail()
        }
    }
    
    private func updateStatusItemTitle() {
        statusItem.button?.title = "#email: \(counter)"
    }
    
    @objc private func incrementCounter() {
        counter += 1
        showNotification(title: "Counter Incremented", message: "Counter is now \(counter)")
    }
    
    @objc private func decrementCounter() {
        counter = max(0, counter - 1)
        showNotification(title: "Counter Decremented", message: "Counter is now \(counter)")
    }
    
    @objc private func copyEmail() {
        let email = emailTemplate.replacingOccurrences(of: "{count}", with: String(counter))
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(email, forType: .string)
        showNotification(title: "Email Copied", message: email)
    }
    
    @objc private func resetCounter() {
        counter = 0
        showNotification(title: "Counter Reset", message: "Counter is now 0")
    }
    
    @objc private func toggleLaunchAtLogin(_ sender: NSMenuItem) {
        if #available(macOS 13.0, *) {
            do {
                if SMAppService.mainApp.status == .enabled {
                    try SMAppService.mainApp.unregister()
                    sender.state = .off
                } else {
                    try SMAppService.mainApp.register()
                    sender.state = .on
                }
            } catch {
                print("Failed to toggle launch at login: \(error)")
            }
        }
    }
    
    private func requestNotificationPermissions() {
        if #available(macOS 10.14, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
                if granted {
                    print("Notification permissions granted")
                }
            }
        }
    }
    
    private func showNotification(title: String, message: String) {
        if #available(macOS 10.14, *) {
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = message
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
            UNUserNotificationCenter.current().add(request)
        } else {
            let notification = NSUserNotification()
            notification.title = title
            notification.informativeText = message
            NSUserNotificationCenter.default.deliver(notification)
        }
    }
    
    @objc private func showEmailConfiguration() {
        if configWindow == nil {
            let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 500, height: 200),
                                  styleMask: [.titled, .closable],
                                  backing: .buffered, defer: false)
            window.title = "Configure Email Template"
            window.center()
            
            let contentView = NSView(frame: window.contentView!.bounds)
            contentView.autoresizingMask = [.width, .height]
            
            let label = NSTextField(labelWithString: "Email Template:")
            label.frame = NSRect(x: 20, y: 140, width: 460, height: 20)
            contentView.addSubview(label)
            
            let helpText = NSTextField(labelWithString: "Use {count} as a placeholder for the counter value")
            helpText.font = NSFont.systemFont(ofSize: 11)
            helpText.textColor = NSColor.secondaryLabelColor
            helpText.frame = NSRect(x: 20, y: 115, width: 460, height: 20)
            contentView.addSubview(helpText)
            
            let textField = NSTextField(frame: NSRect(x: 20, y: 80, width: 460, height: 24))
            textField.stringValue = emailTemplate
            textField.placeholderString = "email+{count}@example.com"
            textField.delegate = self
            textField.tag = 100
            contentView.addSubview(textField)
            
            let exampleLabel = NSTextField(labelWithString: "")
            exampleLabel.font = NSFont.systemFont(ofSize: 11)
            exampleLabel.textColor = NSColor.tertiaryLabelColor
            exampleLabel.frame = NSRect(x: 20, y: 55, width: 460, height: 20)
            exampleLabel.tag = 101
            contentView.addSubview(exampleLabel)
            updateExampleLabel(exampleLabel, with: emailTemplate)
            
            let saveButton = NSButton(frame: NSRect(x: 380, y: 20, width: 100, height: 30))
            saveButton.title = "Save"
            saveButton.bezelStyle = .rounded
            saveButton.target = self
            saveButton.action = #selector(saveEmailTemplate)
            saveButton.keyEquivalent = "\r"
            contentView.addSubview(saveButton)
            
            let cancelButton = NSButton(frame: NSRect(x: 270, y: 20, width: 100, height: 30))
            cancelButton.title = "Cancel"
            cancelButton.bezelStyle = .rounded
            cancelButton.target = self
            cancelButton.action = #selector(cancelEmailConfiguration)
            contentView.addSubview(cancelButton)
            
            window.contentView = contentView
            configWindow = window
        }
        
        configWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc private func saveEmailTemplate() {
        if let textField = configWindow?.contentView?.viewWithTag(100) as? NSTextField {
            let newTemplate = textField.stringValue
            if !newTemplate.isEmpty && newTemplate.contains("{count}") {
                emailTemplate = newTemplate
                configWindow?.close()
                showNotification(title: "Template Saved", message: "Email template updated successfully")
            } else {
                let alert = NSAlert()
                alert.messageText = "Invalid Template"
                alert.informativeText = "Template must contain {count} placeholder"
                alert.alertStyle = .warning
                alert.addButton(withTitle: "OK")
                alert.runModal()
            }
        }
    }
    
    @objc private func cancelEmailConfiguration() {
        configWindow?.close()
    }
    
    func controlTextDidChange(_ obj: Notification) {
        if let textField = obj.object as? NSTextField,
           let exampleLabel = configWindow?.contentView?.viewWithTag(101) as? NSTextField {
            updateExampleLabel(exampleLabel, with: textField.stringValue)
        }
    }
    
    private func updateExampleLabel(_ label: NSTextField, with template: String) {
        let example = template.replacingOccurrences(of: "{count}", with: String(counter))
        label.stringValue = "Example: \(example)"
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        hotKeyManager?.unregisterAllHotKeys()
    }
}