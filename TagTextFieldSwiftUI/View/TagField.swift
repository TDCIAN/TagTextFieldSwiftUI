//
//  TagField.swift
//  TagTextFieldSwiftUI
//
//  Created by 김정민 on 2023/09/17.
//

import SwiftUI

struct TagField: View {
    @Binding var tags: [Tag]
    var body: some View {
        TagLayout(alignment: .leading) {
            ForEach(self.$tags) { $tag in
                TagView(tag: $tag, allTags: self.$tags)
                    .onChange(of: tag.value) { oldValue, newValue in
                        if newValue.last == "," {
                            /// Removing Comma
                            tag.value.removeLast()
                            /// Inserting New Tag Item
                            if !tag.value.isEmpty {
                                /// Safe check
                                self.tags.append(.init(value: ""))
                            }
                        }
                    }
            }
        }
        .clipped()
        .padding(.vertical, 10)
        .padding(.horizontal, 15)
        .background(.bar, in: .rect(cornerRadius: 12))
        .onAppear(perform: {
            /// Initializing Tag View
            /*
             Video Time: (03:10 / 14:19)
             - Since at the beginning the tagview will be empty,
             I'm going to initialise it with an empty and non-interactable tagview,
             which will become interactable once it's tapped for the first time.
             */
            if tags.isEmpty {
                tags.append(.init(value: "", isInitial: true))
            }
        })
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification), perform: { _ in
            if let lastTag = self.tags.last, !lastTag.value.isEmpty {
                /// Inserting empty tag at last
                self.tags.append(.init(value: "", isInitial: true))
            }
        })
    }
}

/// Tag View
fileprivate struct TagView: View {
    @Binding var tag: Tag
    @Binding var allTags: [Tag]
    @FocusState private var isFocused: Bool // For each tag view, a separate view is created to retain the keyboard status so that switching between them is simple.
    /// View Properties
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        BackSpaceListenerTextField(hint: "Tag", text: self.$tag.value, onBackPressed: {
            if self.allTags.count > 1 {
                if self.tag.value.isEmpty {
                    self.allTags.removeAll(where: { $0.id == self.tag.id })
                    /// Activating the previously available Tag
                    if let lastIndex = self.allTags.indices.last {
                        self.allTags[lastIndex].isInitial = false
                    }
                }
            }
        })
            .focused(self.$isFocused)
            .padding(.horizontal, self.isFocused || self.tag.value.isEmpty ? 0 : 10)
            .padding(.vertical, 10)
            .background((self.colorScheme == .dark ? Color.black : Color.white).opacity(self.isFocused || self.tag.value.isEmpty ? 0 : 1), in: .rect(cornerRadius: 5))
            .disabled(self.tag.isInitial)
            .onChange(of: self.allTags, initial: true, { oldValue, newValue in
                /*
                 Video Time: (05:14 / 14:19)
                 - Sow what I'm going to do is simple: with the new onChange modifier,
                 I can avoid the use of the onAppear modifier.
                 Thus, when the tags are updated, I will verify if the last tag in the array matches the given tag, and if those two match, I will activate the keyboard.
                 This will shift the keyboard from old to new since the newest will be the last one.
                 */
                if newValue.last?.id == self.tag.id && !(newValue.last?.isInitial ?? false) && !self.isFocused {
                    self.isFocused = true
                }
            })
            .overlay {
                if self.tag.isInitial {
                    Rectangle()
                        .fill(.clear)
                        .contentShape(.rect)
                        .onTapGesture {
                            /// Activating only for last Tag
                            if self.allTags.last?.id == self.tag.id {
                                self.tag.isInitial = false
                                self.isFocused = true
                            }
                        }
                }
            }
            .onChange(of: self.isFocused) { _, _ in
                if !self.isFocused {
                    self.tag.isInitial = true
                }
            }
    }
}

fileprivate struct BackSpaceListenerTextField: UIViewRepresentable {
    var hint: String = "Tag"
    @Binding var text: String
    var onBackPressed: () -> ()
    
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(text: self.$text)
    }
    func makeUIView(context: Context) -> CustomTextField {
        let textField = CustomTextField()
        textField.delegate = context.coordinator
        textField.onBackPressed = self.onBackPressed
        /// Optionals
        textField.placeholder = self.hint
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .words
        textField.backgroundColor = .clear
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textChange(textField:)), for: .editingChanged)
        return textField
    }
    
    func updateUIView(_ uiView: CustomTextField, context: Context) {
        uiView.text = self.text
    }
    
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: CustomTextField, context: Context) -> CGSize? {
        /*
         Video Time: (07:05 / 14: 19)
         - This will maintain the textfield to take the required space rather than the whole available space.
         */
        return uiView.intrinsicContentSize
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        init(text: Binding<String>) {
            self._text = text
        }
        
        /// Text Change
        @objc func textChange(textField: UITextField) {
            self.text = textField.text ?? ""
        }
        
        /// Closing on Pressing Return Button
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
        }
    }
}

fileprivate class CustomTextField: UITextField {
    open var onBackPressed: (() -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func deleteBackward() {
        /// This will be called when ever keyboard back button is pressed
        self.onBackPressed?()
        super.deleteBackward()
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
}

#Preview {
    ContentView()
}
