import LoginTemplate from '../../shared/components/auth/LoginTemplate';

export default function TrainersLoginPage() {
  return (
    <LoginTemplate
      allowedRoles={['HEAD_OF_TRAINERS', 'TRAINER', 'SALES_MANAGER', 'SM', 'REGIONAL_MANAGER', 'RM']}
      portalName="Sales Manager Dashboard"
      portalDescription="Agent management, client conversion tracking, training coordination and daily performance reporting."
      primaryColor="#7c3aed"
      sidebarColor="#2e1065"
      accentColor="#22c55e"
      features={[
        'Agent assignment and reassignment',
        'Client conversion pipeline',
        'Regional manager performance by country',
        'Priority listing modification',
        'CFO direct communication',
      ]}
    />
  );
}


