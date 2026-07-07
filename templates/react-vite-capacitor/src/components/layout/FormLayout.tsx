import type { FormEventHandler, ReactNode } from "react";
import { zodResolver } from "@hookform/resolvers/zod";
import { useForm } from "react-hook-form";
import { z } from "zod";
import { Button } from "../ui/button";
import { Form, FormControl, FormField, FormItem, FormLabel, FormMessage } from "../ui/form";
import { Input } from "../ui/input";
import "./layouts.css";

type FormLayoutProps = {
  children: ReactNode;
  actions: ReactNode;
  isPending?: boolean;
  onSubmit: FormEventHandler<HTMLFormElement>;
};

export function FormLayout({ actions, children, isPending = false, onSubmit }: FormLayoutProps) {
  return (
    <form aria-busy={isPending} className="form-layout" onSubmit={onSubmit}>
      <fieldset className="form-layout__fields" disabled={isPending}>
        {children}
      </fieldset>
      <div className="form-layout__actions">{actions}</div>
    </form>
  );
}

const formLayoutExampleSchema = z.object({
  workspaceName: z.string().trim().min(1, "Enter a workspace name."),
  ownerEmail: z.email("Enter a valid owner email."),
});

type FormLayoutExampleValues = z.infer<typeof formLayoutExampleSchema>;

type FormLayoutExampleProps = {
  isPending?: boolean;
  onSubmit?: (values: FormLayoutExampleValues) => void | Promise<void>;
};

export function FormLayoutExample({
  isPending = false,
  onSubmit,
}: FormLayoutExampleProps) {
  const form = useForm<FormLayoutExampleValues>({
    resolver: zodResolver(formLayoutExampleSchema),
    defaultValues: {
      workspaceName: "",
      ownerEmail: "",
    },
  });

  return (
    <Form {...form}>
      <FormLayout
        isPending={isPending}
        onSubmit={form.handleSubmit(async (values) => {
          await onSubmit?.(values);
        })}
        actions={
          <Button type="submit" disabled={isPending}>
            Save settings
          </Button>
        }
      >
        <FormField
          control={form.control}
          name="workspaceName"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Workspace name</FormLabel>
              <FormControl>
                <Input placeholder="Operations workspace" {...field} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />
        <FormField
          control={form.control}
          name="ownerEmail"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Owner email</FormLabel>
              <FormControl>
                <Input placeholder="owner@example.com" type="email" {...field} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />
      </FormLayout>
    </Form>
  );
}
