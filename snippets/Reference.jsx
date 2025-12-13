export const Reference = () => {
  const items = [
    {
      href: "https://e2b.dev/docs/sdk-reference",
      title: "SDK Reference",
      description:
        "Complete reference for the E2B SDK with all classes and methods.",
      icon: "code",
    },
    {
      href: "https://e2b.dev/docs/api-reference",
      title: "API Reference",
      description:
        "Full REST API documentation for managing sandboxes programmatically.",
      icon: "brackets-curly",
    }
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
