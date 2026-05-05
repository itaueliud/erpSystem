import axios, { AxiosInstance } from 'axios';
import { config } from '../../config';
import logger from '../../utils/logger';

export type EmailableState = 'deliverable' | 'undeliverable' | 'risky' | 'unknown';

export interface EmailVerificationResult {
  isDeliverable: boolean;
  isAcceptedForSignup: boolean;
  state: EmailableState;
  reason?: string | null;
  score?: number | null;
  raw?: any;
}

interface EmailableVerifyResponse {
  state: EmailableState;
  reason?: string | null;
  score?: number | null;
}

export class EmailableClient {
  private readonly client: AxiosInstance;
  private readonly apiKey: string;
  private readonly enabled: boolean;
  private readonly strictDeliverableOnly: boolean;

  constructor() {
    this.client = axios.create({
      baseURL: 'https://api.emailable.com/v1',
      timeout: 10000,
    });
    this.apiKey = config.emailable.apiKey;
    this.enabled = Boolean(this.apiKey);
    this.strictDeliverableOnly = config.emailable.strictDeliverableOnly;

    if (!this.enabled) {
      logger.warn('Emailable API key not configured - email verification will be skipped');
    }
  }

  async verifyEmail(email: string): Promise<EmailVerificationResult> {
    const normalizedEmail = String(email || '').trim().toLowerCase();
    if (!normalizedEmail) {
      throw new Error('Email is required for verification');
    }

    if (!this.enabled) {
      return {
        isDeliverable: true,
        isAcceptedForSignup: true,
        state: 'unknown',
        reason: 'emailable_not_configured',
        score: null,
      };
    }

    try {
      const response = await this.client.get<EmailableVerifyResponse>('/verify', {
        params: {
          email: normalizedEmail,
          api_key: this.apiKey,
        },
      });

      const state = response.data?.state || 'unknown';
      const reason = response.data?.reason ?? null;
      const score = response.data?.score ?? null;
      const isDeliverable = state === 'deliverable';
      const isAcceptedForSignup = this.strictDeliverableOnly
        ? state === 'deliverable'
        : state === 'deliverable' || state === 'risky' || state === 'unknown';

      return {
        isDeliverable,
        isAcceptedForSignup,
        state,
        reason,
        score,
        raw: response.data,
      };
    } catch (error: any) {
      const status = error?.response?.status;
      const message = error?.response?.data?.message || error?.message || 'Emailable verification failed';

      logger.error('Emailable API verification error', { email: normalizedEmail, status, message });

      // If Emailable is down or rate-limiting, allow registration rather than blocking all signups.
      if ([249, 429, 500, 503].includes(status)) {
        return {
          isDeliverable: false,
          isAcceptedForSignup: true,
          state: 'unknown',
          reason: `emailable_temporary_error_${status}`,
          score: null,
        };
      }

      throw new Error(`Email verification failed: ${message}`);
    }
  }
}

export const emailableClient = new EmailableClient();
export default emailableClient;

