export const LegacyWarning = ({ children }) => {
  return (
    <div className="sticky lg:top-2 top-32 z-20 backdrop-blur-sm bg-white/80 dark:bg-black/80 legacy-notice">
      <Danger>
        {children}
      </Danger>
    </div>
  );
};
