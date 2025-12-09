export const Examples = () => {
  const items = [
    {
      href: "/docs/",
      title: "AI Data Analysis & Visualization",
      description:
        "Run data analysis and generate visualizations with AI in secure sandboxes.",
      icon: "chart-line",
    },
    {
      href: "/docs/",
      title: "Coding Agents",
      description:
        "Build autonomous coding agents that write, test, and deploy code safely.",
      icon: "robot",
    },
    {
      href: "/docs/",
      title: "Vibe Coding",
      description:
        "Create interactive coding experiences with real-time execution environments.",
      icon: "wand-magic-sparkles",
    },
    {
      href: "/docs/",
      title: "Reinforcement Learning",
      description:
        "Train and test RL models in isolated, reproducible sandbox environments.",
      icon: "brain",
    },
    {
      href: "/docs/",
      title: "Computer Use",
      description:
        "Enable AI models to interact with computers and execute tasks autonomously.",
      icon: "computer",
    },
  ];
  return (
    <Columns cols={2}>
      {items.map((i) => (
        <Card title={i.title} href={i.href} icon={i.icon}>
          {i.description}
        </Card>
      ))}
    </Columns>
  );
};
