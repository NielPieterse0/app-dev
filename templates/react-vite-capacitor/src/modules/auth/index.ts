// Disposable auth example scaffolding for generated apps. Replace or remove this
// module once the product-specific auth contract is defined.
export { useAuthSession } from "./hooks/useAuthSession";
export { requireAuthSession } from "./loaders/requireAuthSession";
export { signInWithEmailOtp, signOut } from "./services/auth-service";
