import { render } from "@testing-library/react-native";
import App, { appCopy } from "../App";

test("renders starter Expo screen", async () => {
  const { getByText } = await render(<App />);

  expect(getByText(appCopy.title)).toBeTruthy();
});
