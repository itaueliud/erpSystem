import { AuthProvider } from '../../shared/components/auth/AuthContext';
import { BrowserRouter, Routes, Route } from '../../shared/utils/router';
import PortalGuard from '../../shared/components/auth/PortalGuard';
import { RealtimeProvider } from '../../shared/utils/RealtimeContext';
import TrainersPortal from './index';
import TrainersLoginPage from './TrainersLoginPage';

const ALLOWED_ROLES = ['HEAD_OF_TRAINERS', 'TRAINER', 'SALES_MANAGER', 'SM', 'REGIONAL_MANAGER', 'RM'];

export default function TrainersApp() {
  return (
    <AuthProvider>
      <RealtimeProvider>
        <BrowserRouter>
          <Routes>
            <Route path="/login" element={<TrainersLoginPage />} />
            <Route path="/*" element={
              <PortalGuard allowedRoles={ALLOWED_ROLES} portalName="Sales Manager Dashboard">
                <TrainersPortal />
              </PortalGuard>
            } />
          </Routes>
        </BrowserRouter>
      </RealtimeProvider>
    </AuthProvider>
  );
}
