import LoginTemplate from '../../shared/components/auth/LoginTemplate';

export default function OperationsLoginPage() {
  return (
    <LoginTemplate
      allowedRoles={['OPERATIONS_USER','HEAD_OF_TRAINERS','TRAINER','REGIONAL_MANAGER','SALES_MANAGER','RM','SM','CLIENT_SUCCESS_USER','ACCOUNT_EXECUTIVE','SENIOR_ACCOUNT_MANAGER','MARKETING_USER','MARKETING_OFFICER']}
      portalName="Operations Portal"
      portalDescription="Sales, client acquisition, client success management, marketing operations and regional manager coordination."
      primaryColor="#0f766e"
      sidebarColor="#042f2e"
      accentColor="#f97316"
      features={[
        'Client acquisition and lead management',
        'Client success and account management',
        'Marketing campaign tracking',
        'Regional manager and agent performance',
        'Daily report submission',
      ]}
    />
  );
}

