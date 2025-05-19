import SwiftUI
import Combine
#if canImport(UIKit)
import UIKit
#endif

struct LoginView: View {
    @EnvironmentObject private var authService: AuthenticationService
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    @State private var loginCancellable: AnyCancellable?
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case email
        case password
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.purple.opacity(0.7)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            // Login form
            ScrollView {
                VStack(spacing: 30) {
                    // Logo
                    VStack(spacing: 10) {
                        Image(systemName: "graduationcap.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .foregroundColor(.white)
                        
                        Text("Compass4Success")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Teacher Portal")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.top, 50)
                    .padding(.bottom, 20)
                    
                    // Login card
                    VStack(spacing: 25) {
                        Text("Sign In")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        // Email field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            TextField("teacher@school.edu", text: $email)
                                #if os(iOS)
                                .textContentType(UITextContentType.emailAddress)
                                .keyboardType(UIKeyboardType.emailAddress)
                                .autocapitalization(UITextAutocapitalizationType.none)
                                #endif
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .focused($focusedField, equals: .email)
                                #if os(iOS)
                                .submitLabel(SubmitLabel.next)
                                #endif
                                .onSubmit {
                                    focusedField = .password
                                }
                        }
                        
                        // Password field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            SecureField("Enter password", text: $password)
                                #if os(iOS)
                                .textContentType(UITextContentType.password)
                                #endif
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .focused($focusedField, equals: .password)
                                #if os(iOS)
                                .submitLabel(SubmitLabel.go)
                                #endif
                                .onSubmit(login)
                        }
                        
                        // Error message
                        if showError {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.subheadline)
                                .padding(.top, 5)
                        }
                        
                        // Login button
                        Button(action: login) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Login")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                        .disabled(isLoading || !isValid)
                        .opacity(isValid ? 1.0 : 0.6)
                        
                        // Demo mode login
                        Button(action: loginWithDemoAccount) {
                            Text("Login with Demo Account")
                                .fontWeight(.medium)
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                        }
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.blue, lineWidth: 1)
                        )
                        .disabled(isLoading)
                        
                        // Forgot password
                        Button(action: forgotPassword) {
                            Text("Forgot Password?")
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 10)
                        .disabled(isLoading)
                    }
                    .padding(30)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.2), radius: 15, x: 0, y: 5)
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    
                    // App version
                    Text("Version 1.0.0")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.bottom, 20)
                }
                .padding(.horizontal)
                .padding(.vertical, 20)
            }
        }
        .alert("Login Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    // Validation check
    private var isValid: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // Login function
    private func login() {
        guard isValid else { return }
        
        isLoading = true
        errorMessage = ""
        showError = false
        
        loginCancellable = authService.login(email: email, password: password)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    isLoading = false
                    
                    if case .failure(let error) = completion {
                        errorMessage = error.localizedDescription
                        showError = true
                    }
                },
                receiveValue: { _ in
                    // Successfully logged in
                    print("Login successful")
                }
            )
    }
    
    // Auto-fill and login with demo credentials
    private func loginWithDemoAccount() {
        email = "teacher@demo.com"
        password = "password"
        login()
    }
    
    // Handle forgot password
    private func forgotPassword() {
        // Show reset password flow (not implemented)
        errorMessage = "Password reset functionality not implemented yet."
        showError = true
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthenticationService())
    }
}