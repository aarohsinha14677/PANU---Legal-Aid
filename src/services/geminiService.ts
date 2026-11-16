// services/geminiService.ts

import { LegalDraftRequest } from "../../types";
import { Language } from "../../translations";

// API URL for backend generation endpoint.
const API_URL = import.meta.env.VITE_API_URL || "http://localhost:8000";

export async function generateLegalDraft(
  data: LegalDraftRequest,
  language: Language
): Promise<string> {
  try {
    const res = await fetch(`${API_URL}/api/generate-draft`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ data, language }),
    });

    if (!res.ok) {
      let message = "";
      try {
        const errorJson = await res.json();
        message = errorJson.detail || JSON.stringify(errorJson);
      } catch {
        message = await res.text();
      }
      console.error("Backend error response:", res.status, message);
      throw new Error(message || `Backend returned status ${res.status}`);
    }

    const payload = await res.json();
    return payload.draft;
  } catch (error: any) {
    console.error("Error generating legal draft:", error);
    throw error;
  }
}