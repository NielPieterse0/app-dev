import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { FormLayout, FormLayoutExample } from "./FormLayout";

test("FormLayout disables fields while pending", () => {
  render(
    <FormLayout
      isPending
      onSubmit={(event) => {
        event.preventDefault();
      }}
      actions={<button type="submit">Save</button>}
    >
      <input aria-label="Name" />
    </FormLayout>
  );

  expect(screen.getByRole("textbox", { name: "Name" })).toBeDisabled();
});

test("FormLayoutExample surfaces validation content", async () => {
  const user = userEvent.setup();

  render(<FormLayoutExample />);

  await user.click(screen.getByRole("button", { name: "Save settings" }));

  expect(await screen.findByText("Enter a workspace name.")).toBeInTheDocument();
  expect(screen.getByText("Enter a valid owner email.")).toBeInTheDocument();
});
