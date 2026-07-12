import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { EmptyState } from "@/components/state";
import { sourceLabels, type NormalizedSourceItem } from "@/modules/sources";

type SignalDetailCardProps = {
  isPromoting: boolean;
  item: NormalizedSourceItem | null;
  onPromote: () => void;
};

export function SignalDetailCard({ isPromoting, item, onPromote }: SignalDetailCardProps) {
  if (!item) {
    return (
      <EmptyState
        title="Inspect a signal before promotion"
        description="Select a signal from the dashboard table to review its evidence before turning it into a concept draft."
      />
    );
  }

  return (
    <section className="rounded-lg border p-4 space-y-4">
      <div className="flex flex-wrap items-center gap-2">
        <Badge variant="outline">{sourceLabels[item.source]}</Badge>
        <Badge variant="secondary">Score {item.score.toFixed(1)}</Badge>
        <Badge variant="secondary">Engagement {item.engagementCount}</Badge>
      </div>
      <div className="space-y-2">
        <h3 className="text-lg font-semibold">{item.title}</h3>
        <p className="text-sm text-muted-foreground">{item.summary}</p>
        <p className="text-sm text-muted-foreground">
          Published {new Date(item.publishedAt).toLocaleString()} by {item.author}
        </p>
      </div>
      <div className="flex flex-wrap gap-2">
        {item.keywords.map((keyword) => (
          <Badge key={keyword} variant="secondary">
            {keyword}
          </Badge>
        ))}
      </div>
      <div className="flex flex-wrap gap-3">
        <Button type="button" onClick={onPromote} disabled={isPromoting}>
          {isPromoting ? "Promoting concept..." : "Promote to concept"}
        </Button>
        <Button asChild type="button" variant="outline">
          <a href={item.url} rel="noreferrer" target="_blank">
            Open source link
          </a>
        </Button>
      </div>
    </section>
  );
}

