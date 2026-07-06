import { StatusBar } from "expo-status-bar";
import { StyleSheet, Text, View } from "react-native";

export const appCopy = {
  title: "Expo app ready",
  description: "Replace this starter screen with the first native workflow.",
};

export default function App() {
  return (
    <View style={styles.container}>
      <Text style={styles.kicker}>app-dev</Text>
      <Text style={styles.title}>{appCopy.title}</Text>
      <Text style={styles.description}>{appCopy.description}</Text>
      <StatusBar style="auto" />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    alignItems: "center",
    backgroundColor: "#f6f7f9",
    flex: 1,
    justifyContent: "center",
    padding: 24,
  },
  description: {
    color: "#5b6472",
    fontSize: 16,
    lineHeight: 22,
    maxWidth: 360,
    textAlign: "center",
  },
  kicker: {
    color: "#2e7d6f",
    fontSize: 14,
    fontWeight: "700",
    marginBottom: 10,
  },
  title: {
    color: "#18212f",
    fontSize: 30,
    fontWeight: "700",
    lineHeight: 36,
    marginBottom: 10,
    textAlign: "center",
  },
});
