//
//  Supabase.swift
//  Trackme
//
//  Created by Liam Arbuckle on 18/06/2025.
//

import Foundation
import Supabase

let supabase = SupabaseClient(
    supabaseURL: URL(string: "http://127.0.0.1:54321")!,
    supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0"
)
