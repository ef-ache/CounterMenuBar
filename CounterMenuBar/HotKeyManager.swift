import Cocoa
import Carbon

class HotKeyManager {
    
    private var hotKeys: [EventHotKeyRef?] = []
    private var handlers: [UInt32: () -> Void] = [:]
    private var nextID: UInt32 = 1
    
    init() {
        setupEventHandler()
    }
    
    deinit {
        unregisterAllHotKeys()
    }
    
    private func setupEventHandler() {
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        
        InstallEventHandler(GetApplicationEventTarget(), { (nextHandler, event, userData) -> OSStatus in
            guard let userData = userData else { return noErr }
            
            let manager = Unmanaged<HotKeyManager>.fromOpaque(userData).takeUnretainedValue()
            
            var hotKeyID = EventHotKeyID()
            GetEventParameter(event, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID),
                            nil, MemoryLayout<EventHotKeyID>.size, nil, &hotKeyID)
            
            if let handler = manager.handlers[hotKeyID.id] {
                DispatchQueue.main.async {
                    handler()
                }
            }
            
            return noErr
        }, 1, &eventType, Unmanaged.passUnretained(self).toOpaque(), nil)
    }
    
    func registerHotKey(keyCode: Int, modifiers: NSEvent.ModifierFlags, handler: @escaping () -> Void) {
        let hotKeyID = EventHotKeyID(signature: OSType(0x484B4559), id: nextID)
        nextID += 1
        
        var carbonModifiers: UInt32 = 0
        if modifiers.contains(.command) {
            carbonModifiers |= UInt32(cmdKey)
        }
        if modifiers.contains(.shift) {
            carbonModifiers |= UInt32(shiftKey)
        }
        if modifiers.contains(.option) {
            carbonModifiers |= UInt32(optionKey)
        }
        if modifiers.contains(.control) {
            carbonModifiers |= UInt32(controlKey)
        }
        
        var hotKeyRef: EventHotKeyRef?
        let status = RegisterEventHotKey(UInt32(keyCode), carbonModifiers, hotKeyID,
                                        GetApplicationEventTarget(), 0, &hotKeyRef)
        
        if status == noErr {
            hotKeys.append(hotKeyRef)
            handlers[hotKeyID.id] = handler
        }
    }
    
    func unregisterAllHotKeys() {
        for hotKey in hotKeys {
            if let hotKey = hotKey {
                UnregisterEventHotKey(hotKey)
            }
        }
        hotKeys.removeAll()
        handlers.removeAll()
    }
}